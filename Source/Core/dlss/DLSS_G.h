#pragma once

#include "../includes/frame_generation.h"

// DLSS-G requires Streamline SDK
// Check if Streamline headers are available
// Only auto-enable if ENABLE_DLSS_G is not already defined (allows explicit disable via #define ENABLE_DLSS_G 0)
#if !defined(ENABLE_DLSS_G)
   #if defined(_WIN64) && __has_include(<sl.h>)
      #define ENABLE_DLSS_G 1
   #else
      #define ENABLE_DLSS_G 0
   #endif
#endif

#if ENABLE_DLSS_G

#include <sl.h>
#include <sl_consts.h>
#include <sl_dlss_g.h>
#include <sl_reflex.h>
#include <unordered_set>

namespace NGX
{
   // Global Streamline initialization state
   // NOTE: Streamline ideally should be initialized before D3D12 device creation.
   // In ReShade addon context, we use manual hooking mode which allows device to
   // be created before slInit. We then use slSetD3DDevice and slUpgradeInterface
   // to integrate with the existing device and swapchain.
   struct StreamlineState
   {
      bool init_attempted = false;
      bool init_succeeded = false;
      sl::Result init_result = sl::Result::eErrorNotInitialized;

      // Track which device was last set with slSetD3DDevice
      void* current_device = nullptr;

      // Attempt to initialize Streamline SDK
      // Should be called as early as possible (ideally before any D3D12/DXGI calls)
      bool TryInit();

      // Shutdown Streamline SDK - call on device destruction
      void Shutdown();

      // Reset state for device recreation (without full shutdown)
      void OnDeviceDestroyed(void* device);

      // Set the D3D device for Streamline (handles device changes)
      sl::Result SetDevice(void* device);

      // Check if a feature is supported
      bool IsFeatureSupported(sl::Feature feature, IDXGIAdapter* adapter = nullptr);

      // Upgrade a swapchain to Streamline proxy (for manual hooking)
      // Returns the proxy swapchain (same pointer if already upgraded or if upgrade fails)
      IDXGISwapChain* UpgradeSwapchain(IDXGISwapChain* swapchain);

      // Track which swapchains have been upgraded
      std::unordered_set<IDXGISwapChain*> upgraded_swapchains;

      static StreamlineState& Get()
      {
         static StreamlineState instance;
         return instance;
      }

   private:
      StreamlineState() = default;
   };

   // DLSS-G Frame Generation Implementation
   // Requires Streamline SDK integration and an RTX 40+ series GPU (Ada or newer)
   class DLSS_G : public FG::FrameGenerationImpl
   {
   public:
      virtual bool HasInit(const FG::InstanceData* data) const override;
      virtual bool IsSupported(const FG::InstanceData* data) const override;

      virtual bool Init(FG::InstanceData*& data, ID3D11Device* device, FG::FrameGenerationContext* context, IDXGIAdapter* adapter = nullptr) override;
      virtual void Deinit(FG::InstanceData*& data) override;

      virtual bool UpdateSettings(FG::InstanceData* data, ID3D11DeviceContext* command_list, const FG::SettingsData& settings_data) override;

      virtual bool Dispatch(FG::InstanceData* data, ID3D11DeviceContext* command_list, const FG::DispatchData& dispatch_data) override;

      virtual void OnPresentBegin(FG::InstanceData* data, IDXGISwapChain* swapchain = nullptr) override;
      virtual void OnPresentEnd(FG::InstanceData* data, IDXGISwapChain* swapchain = nullptr) override;

      virtual const char* GetName() const override { return "DLSS-G"; }
      virtual FG::Type GetType() const override { return FG::Type::DLSS_G; }

   private:
      // Set Reflex markers for frame pacing
      void SetReflexMarker(FG::InstanceData* data, sl::PCLMarker marker);
   };

   // DLSS-G specific instance data
   struct DLSS_G_InstanceData : public FG::InstanceData
   {
      // Streamline viewport ID
      sl::ViewportHandle viewport_handle = {};

      // Feature status
      bool streamline_available = false;
      bool reflex_available = false;
      sl::DLSSGMode current_mode = sl::DLSSGMode::eOff;

      // Frame tracking
      uint64_t frame_index = 0;

      // Cached state
      unsigned int num_frames_to_generate_max = 1;

      // Proxy swapchain returned by slUpgradeInterface
      // Used for testing manual proxy Present calls
      IDXGISwapChain* proxy_swapchain = nullptr;
      bool proxy_is_different = false; // True if proxy != original (wrapper was created)

      virtual ~DLSS_G_InstanceData() override = default;
   };

} // namespace NGX

#endif // ENABLE_DLSS_G
