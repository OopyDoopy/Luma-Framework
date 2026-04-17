// ---------------------------------------------------------------------------
// UI-phase detection and background upscaling for Granblue Fantasy Relink.
//
// scaled_texture (RGBA16F, output resolution) is pre-allocated in OnInitSwapchain
// and kept valid for the lifetime of a swapchain. When the first UI draw is
// detected on a deferred context, the current scene render target is bilinearly
// copied into scaled_texture. All subsequent UI draws on that context are
// redirected to scaled_texture. The output shader always reads from scaled_texture
// with identity UVs — no conditional gating needed because the output command list
// always executes after the UI command list.
// ---------------------------------------------------------------------------

// Creates / recreates scaled_texture at output resolution (DXGI_FORMAT_R16G16B16A16_FLOAT).
// The swapchain is upgraded to scRGB / RGBA16F and scaled_texture is copied to the back
// buffer, so they must match. No-op if size and format are already correct.
static void EnsureScaledTexture(DeviceData& device_data, GameDeviceDataGBFR& game_device_data)
{
   const UINT out_w = static_cast<UINT>(device_data.output_resolution.x);
   const UINT out_h = static_cast<UINT>(device_data.output_resolution.y);
   if (!out_w || !out_h)
      return;

   D3D11_TEXTURE2D_DESC desc = {};
   desc.Width = out_w;
   desc.Height = out_h;
   desc.MipLevels = 1;
   desc.ArraySize = 1;
   desc.Format = DXGI_FORMAT_R16G16B16A16_FLOAT;
   desc.SampleDesc.Count = 1;
   desc.Usage = D3D11_USAGE_DEFAULT;
   desc.BindFlags = D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_RENDER_TARGET;

   auto& ui_scale = game_device_data.ui_scale;
   CreateOrRecreateTextureIfNeeded(
      game_device_data, device_data.native_device, desc,
      ui_scale.scaled_texture, ui_scale.scaled_texture_srv, ui_scale.scaled_texture_rtv);
}

// Detects the UI phase by blend state / sampler / depth / SRV signature.
// On first detection, copies the scene to an output-resolution texture with
// bilinear filtering and redirects the render target + viewport.
// Returns true when the draw is part of the UI phase.
static bool DetectUIPhase(DeviceData& device_data, ID3D11DeviceContext* ctx)
{
   auto& game_device_data = *static_cast<GameDeviceDataGBFR*>(device_data.game);
   auto& ui_scale = game_device_data.ui_scale;

   const ID3D11DeviceContext* ui_ctx = game_device_data.ui_detected_context.load(std::memory_order_acquire);
   if (ui_ctx != nullptr)
   {
      if (ui_ctx == ctx)
         return true;
      // Different context — fall through to check blend state.
   }

   // --- Blend state check (any alpha blending) ---
   com_ptr<ID3D11BlendState> blend_state;
   ctx->OMGetBlendState(&blend_state, nullptr, nullptr);
   if (!blend_state)
      return false;

   D3D11_BLEND_DESC bd;
   blend_state->GetDesc(&bd);
   if (!bd.RenderTarget[0].BlendEnable)
      return false;

   // --- Sampler check (bilinear) ---
   com_ptr<ID3D11SamplerState> sampler_state;
   ctx->PSGetSamplers(0, 1, &sampler_state);
   if (!sampler_state)
      return false;
   D3D11_SAMPLER_DESC sd;
   sampler_state->GetDesc(&sd);
   if (sd.Filter != D3D11_FILTER_MIN_MAG_MIP_LINEAR)
      return false;

   // --- Depth disabled ---
   com_ptr<ID3D11DepthStencilState> depth_stencil_state;
   ctx->OMGetDepthStencilState(&depth_stencil_state, nullptr);
   if (!depth_stencil_state)
      return false;
   D3D11_DEPTH_STENCIL_DESC dsd;
   depth_stencil_state->GetDesc(&dsd);
   if (dsd.DepthEnable)
      return false;

   // --- SRV 0 format check (BC7, BC4, 1x1 RGBA8, or RGBA16F at output resolution) ---
   // The last case covers the pause-game UI path where the game copies a previous
   // scene frame (already at output resolution and in the upgraded RGBA16F format)
   // as the background before drawing UI on top.
   bool srv_matches = false;
   com_ptr<ID3D11ShaderResourceView> srv;
   ctx->PSGetShaderResources(0, 1, &srv);
   if (srv.get())
   {
      D3D11_SHADER_RESOURCE_VIEW_DESC srv_desc;
      srv->GetDesc(&srv_desc);
      const DXGI_FORMAT fmt = srv_desc.Format;
      srv_matches = (fmt == DXGI_FORMAT_BC7_UNORM || fmt == DXGI_FORMAT_BC4_UNORM);
      if (!srv_matches && (fmt == DXGI_FORMAT_R8G8B8A8_UNORM || fmt == DXGI_FORMAT_R16G16B16A16_FLOAT))
      {
         com_ptr<ID3D11Resource> srv_resource;
         srv->GetResource(&srv_resource);
         com_ptr<ID3D11Texture2D> srv_texture;
         srv_resource->QueryInterface(&srv_texture);
         if (srv_texture)
         {
            D3D11_TEXTURE2D_DESC tex_desc;
            srv_texture->GetDesc(&tex_desc);
            if (fmt == DXGI_FORMAT_R8G8B8A8_UNORM)
               srv_matches = (tex_desc.Width == 1 && tex_desc.Height == 1);
            else // RGBA16F: accept only if sized to output resolution
               srv_matches = (tex_desc.Width == static_cast<UINT>(device_data.output_resolution.x) &&
                              tex_desc.Height == static_cast<UINT>(device_data.output_resolution.y));
         }
      }
   }
   if (!srv_matches)
      return false;

   ASSERT_ONCE(ui_ctx == nullptr);

   // ---------------------------------------------------------------
   // First UI draw detected — set up the bilinear copy to output res.
   // The context is NOT cached yet so the copy draw won't re-enter
   // the redirect path (its blend state is disabled, which also fails
   // the blend check above).
   // ---------------------------------------------------------------

   com_ptr<ID3D11RenderTargetView> current_rtv;
   ctx->OMGetRenderTargets(1, &current_rtv, nullptr);
   if (!current_rtv)
   {
      game_device_data.ui_detected_context.store(ctx, std::memory_order_release);
      return true;
   }

   com_ptr<ID3D11Resource> rtv_resource;
   current_rtv->GetResource(&rtv_resource);
   com_ptr<ID3D11Texture2D> scene_texture;
   rtv_resource->QueryInterface(&scene_texture);
   if (!scene_texture)
   {
      game_device_data.ui_detected_context.store(ctx, std::memory_order_release);
      return true;
   }

   D3D11_TEXTURE2D_DESC scene_desc;
   scene_texture->GetDesc(&scene_desc);

   const UINT out_w = static_cast<UINT>(device_data.output_resolution.x);
   const UINT out_h = static_cast<UINT>(device_data.output_resolution.y);

   EnsureScaledTexture(device_data, game_device_data);

   if (!ui_scale.scaled_texture_rtv)
   {
      game_device_data.ui_detected_context.store(ctx, std::memory_order_release);
      return true;
   }

   // Store the original scene texture for later comparison.
   ui_scale.original_scene_texture = scene_texture.get();

   // Create a temporary SRV for the original scene so the copy shader can read it.
   ui_scale.original_scene_srv = nullptr;
   {
      D3D11_SHADER_RESOURCE_VIEW_DESC srv_desc_create = {};
      srv_desc_create.Format = scene_desc.Format;
      srv_desc_create.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2D;
      srv_desc_create.Texture2D.MipLevels = 1;
      srv_desc_create.Texture2D.MostDetailedMip = 0;
      HRESULT hr = device_data.native_device->CreateShaderResourceView(
         scene_texture.get(), &srv_desc_create, ui_scale.original_scene_srv.put());
      if (FAILED(hr) || !ui_scale.original_scene_srv)
      {
         game_device_data.ui_detected_context.store(ctx, std::memory_order_release);
         return true;
      }
   }

   // Look up the native shaders for the bilinear copy.
   const auto vs_it = device_data.native_vertex_shaders.find(CompileTimeStringHash("GBFR Fullscreen UV VS"));
   const auto ps_it = device_data.native_pixel_shaders.find(CompileTimeStringHash("GBFR UI Background Copy"));
   if (vs_it == device_data.native_vertex_shaders.end() || !vs_it->second ||
       ps_it == device_data.native_pixel_shaders.end() || !ps_it->second)
   {
      game_device_data.ui_detected_context.store(ctx, std::memory_order_release);
      return true;
   }

   // Save full graphics state, draw the bilinear copy, then restore.
   {
      DrawStateStack<DrawStateStackType::FullGraphics> state_stack;
      state_stack.Cache(ctx, device_data.uav_max_count);

      // Unbind the original RT so it can be read as SRV.
      ctx->OMSetRenderTargets(0, nullptr, nullptr);

      ID3D11RenderTargetView* const scaled_rtv = ui_scale.scaled_texture_rtv.get();
      ctx->OMSetRenderTargets(1, &scaled_rtv, nullptr);

      ID3D11ShaderResourceView* const scene_srv = ui_scale.original_scene_srv.get();
      ctx->PSSetShaderResources(0, 1, &scene_srv);

      ID3D11SamplerState* const linear_sampler = device_data.sampler_state_linear.get();
      ctx->PSSetSamplers(0, 1, &linear_sampler);

      D3D11_VIEWPORT vp = {};
      vp.Width = static_cast<float>(out_w);
      vp.Height = static_cast<float>(out_h);
      ctx->RSSetViewports(1, &vp);

      ctx->OMSetBlendState(device_data.default_blend_state.get(), nullptr, 0xFFFFFFFF);
      ctx->OMSetDepthStencilState(device_data.default_depth_stencil_state.get(), 0);

      ctx->VSSetShader(vs_it->second.get(), nullptr, 0);
      ctx->PSSetShader(ps_it->second.get(), nullptr, 0);
      ctx->IASetInputLayout(nullptr);
      ctx->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP);
      ctx->Draw(4, 0);

      // Restore state so the Redirect call below can compare properly.
      state_stack.Restore(ctx);
   }

   // Now cache the context — subsequent draws will take the fast path.
   game_device_data.ui_detected_context.store(ctx, std::memory_order_release);

   // Fall through to the redirect for this first UI draw.
   return true;
}

// Redirects a UI draw to the upscaled texture:
//   - Swaps the render target if it still points to the original scene.
//   - Scales the viewport from render resolution to output resolution.
//   - Swaps any SRVs that reference the original scene texture.
static void RedirectUIDrawToScaledTarget(
   ID3D11DeviceContext* ctx,
   DeviceData& device_data,
   GameDeviceDataGBFR& game_device_data)
{
   auto& ui_scale = game_device_data.ui_scale;
   if (!ui_scale.scaled_texture_srv)
      return;

   // --- Render target redirect ---
   {
      com_ptr<ID3D11RenderTargetView> current_rtv;
      ctx->OMGetRenderTargets(1, &current_rtv, nullptr);
      if (current_rtv)
      {
         com_ptr<ID3D11Resource> rtv_resource;
         current_rtv->GetResource(&rtv_resource);
         com_ptr<ID3D11Texture2D> rtv_texture;
         rtv_resource->QueryInterface(&rtv_texture);
         if (rtv_texture.get() == ui_scale.original_scene_texture)
         {
            ID3D11RenderTargetView* const scaled_rtv = ui_scale.scaled_texture_rtv.get();
            ctx->OMSetRenderTargets(1, &scaled_rtv, nullptr);
         }
      }
   }

   // --- Viewport redirect ---
   {
      D3D11_VIEWPORT vp;
      UINT num_vp = 1;
      ctx->RSGetViewports(&num_vp, &vp);
      const UINT render_w = static_cast<UINT>(device_data.render_resolution.x);
      const UINT render_h = static_cast<UINT>(device_data.render_resolution.y);
      if (static_cast<UINT>(vp.Width) == render_w && static_cast<UINT>(vp.Height) == render_h)
      {
         vp.Width = device_data.output_resolution.x;
         vp.Height = device_data.output_resolution.y;
         ctx->RSSetViewports(1, &vp);
      }
   }

   // --- SRV redirect (slots 0–3) ---
   {
      static constexpr UINT kMaxSRVCheck = 4;
      com_ptr<ID3D11ShaderResourceView> srvs[kMaxSRVCheck];
      ctx->PSGetShaderResources(0, kMaxSRVCheck, reinterpret_cast<ID3D11ShaderResourceView**>(&srvs[0]));
      for (UINT i = 0; i < kMaxSRVCheck; ++i)
      {
         if (!srvs[i])
            continue;
         com_ptr<ID3D11Resource> srv_resource;
         srvs[i]->GetResource(&srv_resource);
         com_ptr<ID3D11Texture2D> srv_texture;
         srv_resource->QueryInterface(&srv_texture);
         if (srv_texture.get() == ui_scale.original_scene_texture)
         {
            ID3D11ShaderResourceView* const scaled_srv = ui_scale.scaled_texture_srv.get();
            ctx->PSSetShaderResources(i, 1, &scaled_srv);
         }
      }
   }
}

// Swaps the output shader's input SRV and constant buffer so it reads from
// the upscaled texture with identity UV mapping.
static void HandleOutputShaderForUIScale(
   ID3D11DeviceContext* ctx,
   ID3D11Device* native_device,
   DeviceData& device_data,
   GameDeviceDataGBFR& game_device_data)
{
   auto& ui_scale = game_device_data.ui_scale;
   if (!ui_scale.scaled_texture_srv)
      return;

   // Swap SRV 0 to the upscaled scene+UI texture.
   ID3D11ShaderResourceView* const scaled_srv = ui_scale.scaled_texture_srv.get();
   ctx->PSSetShaderResources(0, 1, &scaled_srv);

   // Create a constant buffer with g_Param = {0, 0, 1, 1} if not yet created.
   // zw = (1,1) makes the output shader's UV transform an identity since the
   // texture is already at output resolution.
   if (!ui_scale.output_param_cbuffer)
   {
      const float param_data[4] = {0.0f, 0.0f, 1.0f, 1.0f};
      D3D11_BUFFER_DESC buf_desc = {};
      buf_desc.ByteWidth = sizeof(param_data);
      buf_desc.Usage = D3D11_USAGE_IMMUTABLE;
      buf_desc.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
      D3D11_SUBRESOURCE_DATA init = {};
      init.pSysMem = param_data;
      native_device->CreateBuffer(&buf_desc, &init, ui_scale.output_param_cbuffer.put());
   }

   if (ui_scale.output_param_cbuffer)
   {
      ID3D11Buffer* const cb = ui_scale.output_param_cbuffer.get();
      ctx->PSSetConstantBuffers(1, 1, &cb);
   }
}