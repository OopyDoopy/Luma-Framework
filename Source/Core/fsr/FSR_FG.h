#pragma once

#include "../includes/frame_generation.h"
#include <d3d11.h>
#include <dxgi1_6.h>

// FSR Frame Generation requires FidelityFX SDK
// Check if FSR 3 Frame Generation headers are available
#if defined(_WIN64) && __has_include("FidelityFX/host/ffx_framegeneration.h")
#ifndef ENABLE_FSR_FG
#define ENABLE_FSR_FG 1
#endif // ENABLE_FSR_FG
#elifdef ENABLE_FSR_FG
#undef ENABLE_FSR_FG
#define ENABLE_FSR_FG 0
#endif

#if ENABLE_FSR_FG

// Forward declarations for FidelityFX types
// In a real implementation, these would come from the FidelityFX SDK headers:
// #include <FidelityFX/host/ffx_framegeneration.h>
// #include <FidelityFX/host/ffx_opticalflow.h>
// #include <FidelityFX/host/backends/dx12/ffx_dx12.h>
struct FfxInterface;
struct FfxOpticalflowContext;
struct FfxFrameGenerationContext;
struct FfxSwapchainReplacementFunctions;

namespace FidelityFX
{
   // ============================================================================
   // FSR-FG Instance Data
   // ============================================================================

   struct FSR_FG_InstanceData : public FG::InstanceData
   {
      // FidelityFX context handles
      FfxOpticalflowContext* optical_flow_context = nullptr;
      FfxFrameGenerationContext* frame_gen_context = nullptr;

      // DX12 backend interface
      FfxInterface* ffx_interface = nullptr;

      // DX12 interop context reference
      FG::FrameGenerationContext* dx12_context = nullptr;

      // Frame tracking
      uint64_t frame_index = 0;
      bool is_active = false;

      // Resource handles for persistent allocations
      void* optical_flow_output = nullptr;
      void* interpolation_output = nullptr;

      // Swapchain replacement (FSR-FG hooks into Present)
      IDXGISwapChain* original_swapchain = nullptr;
      void* ffx_swapchain_context = nullptr;

      // Configuration
      bool async_compute_enabled = false;
      bool hdr_enabled = false;
      bool use_callback_mode = false;

      // Resolution info
      uint32_t render_width = 0;
      uint32_t render_height = 0;
      uint32_t display_width = 0;
      uint32_t display_height = 0;

      virtual ~FSR_FG_InstanceData() override = default;
   };

   // ============================================================================
   // FSR Frame Generation Implementation
   // ============================================================================

   // FSR 3 Frame Generation Implementation
   // Works on AMD, NVIDIA, and Intel GPUs (DX12 only)
   class FSR_FG : public FG::FrameGenerationImpl
   {
   public:
      FSR_FG() = default;
      ~FSR_FG() = default;

      // FG::FrameGenerationBase interface
      const char* GetName() const override { return "FSR Frame Generation"; }
      FG::Type GetType() const override { return FG::Type::FSR_FG; }

      bool HasInit(const FG::InstanceData* data) const override;
      bool IsSupported(const FG::InstanceData* data) const override;

      bool Init(FG::InstanceData*& data, ID3D11Device* device, FG::FrameGenerationContext* context, IDXGIAdapter* adapter = nullptr) override;
      void Deinit(FG::InstanceData*& data) override;

      bool UpdateSettings(FG::InstanceData* data, ID3D11DeviceContext* command_list, const FG::SettingsData& settings_data) override;
      bool Dispatch(FG::InstanceData* data, ID3D11DeviceContext* command_list, const FG::DispatchData& dispatch_data) override;

      void OnPresentBegin(FG::InstanceData* data, IDXGISwapChain* swapchain) override;
      void OnPresentEnd(FG::InstanceData* data, IDXGISwapChain* swapchain) override;

   private:
      // Internal helper methods
      bool InitDX12Backend(FSR_FG_InstanceData* data);
      bool InitOpticalFlow(FSR_FG_InstanceData* data, uint32_t width, uint32_t height);
      bool InitFrameGeneration(FSR_FG_InstanceData* data, uint32_t width, uint32_t height);

      void DestroyOpticalFlow(FSR_FG_InstanceData* data);
      void DestroyFrameGeneration(FSR_FG_InstanceData* data);
      void DestroyDX12Backend(FSR_FG_InstanceData* data);

      // Frame interpolation dispatch
      bool DispatchOpticalFlow(FSR_FG_InstanceData* data, const FG::DispatchData& dispatch_data);
      bool DispatchFrameInterpolation(FSR_FG_InstanceData* data, const FG::DispatchData& dispatch_data);
   };

} // namespace FidelityFX

#endif // ENABLE_FSR_FG
