#include "FSR_FG.h"

#if ENABLE_FSR_FG

#include "../utils/dx12_interop.hpp"
#include "../includes/debug.h"

// FidelityFX SDK headers for Frame Generation
#include "FidelityFX/host/ffx_framegeneration.h"
#include "FidelityFX/host/backends/dx12/ffx_dx12.h"

#include <cstring>
#include <cassert>
#include <wrl/client.h>
#include <d3d11.h>
#include <d3d12.h>

namespace FidelityFX
{

   bool FSR_FG::HasInit(const FG::InstanceData* data) const
   {
      if (!data)
         return false;
      const auto* fsr_data = static_cast<const FSR_FG_InstanceData*>(data);
      return fsr_data->is_initialized && fsr_data->ffx_context != nullptr;
   }

   bool FSR_FG::IsSupported(const FG::InstanceData* data) const
   {
      if (!data)
         return false;
      return data->is_supported;
   }

   bool FSR_FG::Init(FG::InstanceData*& data, ID3D11Device* device, FG::FrameGenerationContext* context, IDXGIAdapter* adapter)
   {
      if (!device || !context)
         return false;

      // Create instance data
      auto* fsr_data = new FSR_FG_InstanceData();
      data = fsr_data;
      fsr_data->is_initialized = false;
      fsr_data->is_supported = false;
      fsr_data->dx12_context = context;

      // FSR Frame Generation requires DX12
      if (!context->IsInitialized())
      {
         if (!context->Init(device))
         {
            // DX12 interop not available
            return false;
         }
      }

      ID3D12Device* dx12_device = context->GetDX12Device();
      if (!dx12_device)
         return false;

      // Check feature level - FSR-FG needs DX12
      D3D_FEATURE_LEVEL feature_level;
      D3D12_FEATURE_DATA_FEATURE_LEVELS levels = {};
      D3D_FEATURE_LEVEL requested_levels[] = {D3D_FEATURE_LEVEL_12_0, D3D_FEATURE_LEVEL_12_1, D3D_FEATURE_LEVEL_12_2};
      levels.NumFeatureLevels = _countof(requested_levels);
      levels.pFeatureLevelsRequested = requested_levels;

      if (SUCCEEDED(dx12_device->CheckFeatureSupport(D3D12_FEATURE_FEATURE_LEVELS, &levels, sizeof(levels))))
      {
         feature_level = levels.MaxSupportedFeatureLevel;
      }
      else
      {
         feature_level = D3D_FEATURE_LEVEL_12_0;
      }

      if (feature_level < D3D_FEATURE_LEVEL_12_0)
      {
         // FSR-FG requires DX12 feature level 12.0+
         return false;
      }

      // FSR-FG is hardware agnostic - it should work on any DX12 capable GPU
      fsr_data->is_supported = true;

      // Set capabilities
      fsr_data->supports_ui_composition = true;  // FSR-FG supports UI composition
      fsr_data->supports_async_compute = true;   // FSR-FG can use async compute
      fsr_data->requires_hud_less_input = false; // FSR-FG doesn't require HUDless, but it helps

      fsr_data->is_initialized = true;

      // Note: The actual FfxContext will be created in UpdateSettings when we know the resolution
      // This follows the same pattern as FSR.cpp

      return true;
   }

   void FSR_FG::Deinit(FG::InstanceData*& data)
   {
      if (!data)
         return;

      auto* fsr_data = static_cast<FSR_FG_InstanceData*>(data);

      // Destroy FFX context if it exists
      if (fsr_data->ffx_context)
      {
         ffxContext* ctx = static_cast<ffxContext*>(fsr_data->ffx_context);

         ffxDestroyContext(ctx, nullptr);

         delete ctx;
         fsr_data->ffx_context = nullptr;
      }

      // Free FFX interface scratch memory
      if (fsr_data->ffx_interface)
      {
         FfxInterface* iface = static_cast<FfxInterface*>(fsr_data->ffx_interface);
         if (iface->scratchBuffer)
         {
            free(iface->scratchBuffer);
         }
         delete iface;
         fsr_data->ffx_interface = nullptr;
      }

      delete fsr_data;
      data = nullptr;
   }

   bool FSR_FG::UpdateSettings(FG::InstanceData* data, ID3D11DeviceContext* command_list, const FG::SettingsData& settings_data)
   {
      if (!data || !data->is_initialized)
         return false;

      auto* fsr_data = static_cast<FSR_FG_InstanceData*>(data);

      // Check if settings actually changed
      bool settings_changed = (data->settings_data.enable != settings_data.enable) ||
                              (data->settings_data.output_width != settings_data.output_width) ||
                              (data->settings_data.output_height != settings_data.output_height) ||
                              (data->settings_data.render_width != settings_data.render_width) ||
                              (data->settings_data.render_height != settings_data.render_height);

      if (!settings_changed && fsr_data->ffx_context)
      {
         return true; // No changes needed
      }

      // Store settings
      data->settings_data = settings_data;

      // If disabling, we can keep the context but won't dispatch
      if (!settings_data.enable)
      {
         return true;
      }

      // Need to create or recreate the FFX context
      FG::FrameGenerationContext* dx12_context = fsr_data->dx12_context;
      if (!dx12_context || !dx12_context->IsInitialized())
         return false;

      ID3D12Device* dx12_device = dx12_context->GetDX12Device();
      if (!dx12_device)
         return false;

      // Destroy existing context if any
      if (fsr_data->ffx_context)
      {
         ffxContext* old_ctx = static_cast<ffxContext*>(fsr_data->ffx_context);
         ffxDestroyContext(old_ctx, nullptr);
         delete old_ctx;
         fsr_data->ffx_context = nullptr;
      }

      // Create FFX interface for DX12
      if (!fsr_data->ffx_interface)
      {
         const size_t scratch_size = ffxGetScratchMemorySizeDX12(1);
         void* scratch = calloc(scratch_size, 1);
         if (!scratch)
            return false;

         FfxInterface* iface = new FfxInterface();
         FfxErrorCode err = ffxGetInterfaceDX12(iface, ffxGetDeviceDX12(dx12_device), scratch, scratch_size, 1);
         if (err != FFX_OK)
         {
            free(scratch);
            delete iface;
            return false;
         }

         fsr_data->ffx_interface = iface;
      }

      // Create new FFX Frame Generation context
      ffxContext* ctx = new ffxContext();

      FfxCreateContextDescFrameGeneration create_desc = {};
      create_desc.header.type = FFX_API_CREATE_CONTEXT_DESC_TYPE_FRAMEGENERATION;
      create_desc.displaySize.width = settings_data.output_width;
      create_desc.displaySize.height = settings_data.output_height;
      create_desc.maxRenderSize.width = settings_data.render_width;
      create_desc.maxRenderSize.height = settings_data.render_height;
      create_desc.backBufferFormat = FfxSurfaceFormat::FFX_SURFACE_FORMAT_R16G16B16A16_FLOAT; // Common format

      // Set flags
      create_desc.flags = 0;
      if (fsr_data->async_compute_enabled)
      {
         create_desc.flags |= FFX_FRAMEGENERATION_ENABLE_ASYNC_WORKLOAD_SUPPORT;
      }
      if (settings_data.mvs_jittered)
      {
         create_desc.flags |= FFX_FRAMEGENERATION_ENABLE_MOTION_VECTORS_JITTER_CANCELLATION;
      }
      if (fsr_data->hdr_enabled)
      {
         create_desc.flags |= FFX_FRAMEGENERATION_ENABLE_HIGH_DYNAMIC_RANGE;
      }

#if DEVELOPMENT
      // Enable debug checking in development
      create_desc.flags |= FFX_FRAMEGENERATION_ENABLE_DEBUG_CHECKING;
#endif

      // Create the context
      FfxInterface* iface = static_cast<FfxInterface*>(fsr_data->ffx_interface);

      FfxCreateBackendDX12Desc backend_desc = {};
      backend_desc.header.type = FFX_API_CREATE_CONTEXT_DESC_TYPE_BACKEND_DX12;
      backend_desc.device = dx12_device;

      FfxReturnCode ret = ffxCreateContext(ctx, &create_desc.header, &backend_desc.header);
      if (ret != FFX_API_RETURN_OK)
      {
         delete ctx;
         return false;
      }

      fsr_data->ffx_context = ctx;

      return true;
   }

   bool FSR_FG::Dispatch(FG::InstanceData* data, ID3D11DeviceContext* command_list, const FG::DispatchData& dispatch_data)
   {
      if (!data || !data->is_initialized || !command_list)
         return false;

      auto* fsr_data = static_cast<FSR_FG_InstanceData*>(data);

      if (!data->settings_data.enable)
         return true; // Not an error, just disabled

      if (!fsr_data->ffx_context || !fsr_data->dx12_context)
         return false;

      ffxContext* ctx = static_cast<ffxContext*>(fsr_data->ffx_context);
      FG::FrameGenerationContext* dx12_ctx = fsr_data->dx12_context;

      // Get shared DX12 resources
      ID3D12Resource* dx12_depth = nullptr;
      ID3D12Resource* dx12_mvec = nullptr;
      ID3D12Resource* dx12_color = nullptr;

      if (dispatch_data.depth)
      {
         dx12_depth = dx12_ctx->GetOrCreateSharedResource(dispatch_data.depth);
      }
      if (dispatch_data.motion_vectors)
      {
         dx12_mvec = dx12_ctx->GetOrCreateSharedResource(dispatch_data.motion_vectors);
      }
      if (dispatch_data.input_color)
      {
         dx12_color = dx12_ctx->GetOrCreateSharedResource(dispatch_data.input_color);
      }

      if (!dx12_depth || !dx12_mvec)
      {
         // Required resources missing
         return false;
      }

      fsr_data->frame_index++;

      // Reset command list
      if (!dx12_ctx->ResetCommandList())
         return false;

      ID3D12GraphicsCommandList* dx12_cmdlist = dx12_ctx->GetCommandList();

      // Prepare dispatch description
      FfxDispatchDescFrameGenerationPrepare prepare_desc = {};
      prepare_desc.header.type = FFX_API_DISPATCH_DESC_TYPE_FRAMEGENERATION_PREPARE;
      prepare_desc.commandList = dx12_cmdlist;
      prepare_desc.frameID = fsr_data->frame_index;
      prepare_desc.reset = dispatch_data.reset;

      // Camera parameters
      prepare_desc.jitterOffset.x = dispatch_data.jitter_x;
      prepare_desc.jitterOffset.y = dispatch_data.jitter_y;
      prepare_desc.cameraNear = dispatch_data.near_plane;
      prepare_desc.cameraFar = dispatch_data.far_plane;
      prepare_desc.cameraFovAngleVertical = dispatch_data.fov;
      prepare_desc.frameTimeDelta = dispatch_data.time_delta * 1000.0f; // Convert to ms

      // Set render size
      prepare_desc.renderSize.width = dispatch_data.render_width;
      prepare_desc.renderSize.height = dispatch_data.render_height;

      // Set resources
      // Note: FSR-FG uses its own resource descriptors
      // This is a simplified version - full implementation needs proper resource conversion

      // Dispatch preparation pass
      FfxReturnCode ret = ffxDispatch(ctx, &prepare_desc.header);
      if (ret != FFX_API_RETURN_OK)
      {
         return false;
      }

      // Execute command list
      if (!dx12_ctx->ExecuteCommandList())
         return false;

      // Signal fence for synchronization
      uint64_t fence_value = dx12_ctx->SignalFence();

      // Wait on DX11 side for DX12 work to complete
      dx12_ctx->WaitForFenceOnDX11(command_list, fence_value);

      return true;
   }

   void FSR_FG::OnPresentBegin(FG::InstanceData* data, IDXGISwapChain* swapchain)
   {
      if (!data)
         return;

      auto* fsr_data = static_cast<FSR_FG_InstanceData*>(data);

      // Called just before Present()
      // FSR-FG swapchain integration would happen here
      // In full implementation, FSR-FG can replace the swapchain to handle
      // frame interpolation during Present

      if (!fsr_data->is_initialized || !data->settings_data.enable)
         return;

      // Store swapchain reference for potential frame interpolation
      fsr_data->original_swapchain = swapchain;
   }

   void FSR_FG::OnPresentEnd(FG::InstanceData* data, IDXGISwapChain* swapchain)
   {
      if (!data)
         return;

      auto* fsr_data = static_cast<FSR_FG_InstanceData*>(data);

      // Called after Present()
      // Clean up any per-frame state if needed

      fsr_data->original_swapchain = nullptr;
   }

} // namespace FidelityFX

#endif // ENABLE_FSR_FG
