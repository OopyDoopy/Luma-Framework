
#pragma once

// State for upscaling the scene background before UI draws so the UI
// renders at output resolution on top of a bilinearly-upscaled scene.
// scaled_texture is pre-allocated in OnInitSwapchain and always valid.
struct UIScaleState
{
   // Persistent resources (recreated only on resolution change).
   ComPtr<ID3D11Texture2D> scaled_texture;
   ComPtr<ID3D11ShaderResourceView> scaled_texture_srv;
   ComPtr<ID3D11RenderTargetView> scaled_texture_rtv;

   // Constant buffer overriding the output shader's g_Param to {0, 0, 1, 1}
   // so its UV mapping becomes identity (texture is already at output res).
   ComPtr<ID3D11Buffer> output_param_cbuffer;

   // Per-frame state — reset in OnPresent.
   ComPtr<ID3D11ShaderResourceView> original_scene_srv; // SRV created for the scene RT
   ID3D11Texture2D* original_scene_texture = nullptr;   // raw pointer for comparison

   void ResetPerFrame()
   {
      original_scene_srv = nullptr;
      original_scene_texture = nullptr;
   }
};