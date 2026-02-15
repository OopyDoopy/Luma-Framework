#include "DLSS_G.h"

#if ENABLE_DLSS_G

// Enable FG (Frame Generation) support since we need DX12 interop for DLSS-G
#ifndef ENABLE_FG
#define ENABLE_FG 1
#endif

// TESTING TOGGLE: Set to 1 to call proxy->Present() in addition to normal Present
// This tests whether slUpgradeInterface creates hooks or requires explicit proxy calls
// Mode 0: Assume slUpgradeInterface hooks the native swapchain vtable (do nothing extra)
// Mode 1: Explicitly call proxySwapchain->Present() during OnPresentBegin
// Mode 2: Same as Mode 1, but only if proxy pointer is different from original
#ifndef DLSS_G_PROXY_PRESENT_MODE
#define DLSS_G_PROXY_PRESENT_MODE 0
#endif

#include "../utils/dx12_interop.hpp"
#include <d3d11.h>
#include <d3d12.h>
#include <dxgi1_6.h>

// Streamline headers
#include <sl.h>
#include <sl_consts.h>
#include <sl_dlss_g.h>
#include <sl_reflex.h>
#include <sl_pcl.h>
#include <sl_helpers.h>

namespace NGX
{
   // ============================================================================
   // StreamlineState Implementation
   // ============================================================================

   // Streamline log callback - forwards to OutputDebugString
   static void StreamlineLogCallback(sl::LogType type, const char* msg)
   {
      const char* typeStr = "INFO";
      switch (type)
      {
      case sl::LogType::eWarn: typeStr = "WARN"; break;
      case sl::LogType::eError: typeStr = "ERROR"; break;
      default: typeStr = "INFO"; break;
      }
      char buffer[2048];
      sprintf_s(buffer, "[Streamline %s] %s\n", typeStr, msg);
      OutputDebugStringA(buffer);
   }

   bool StreamlineState::TryInit()
   {
      if (init_attempted)
         return init_succeeded;

      init_attempted = true;

      // Configure Streamline preferences
      sl::Preferences pref{};
#if DEVELOPMENT
      pref.showConsole = true;  // Show Streamline console window in dev builds
      pref.logLevel = sl::LogLevel::eVerbose;
      pref.logMessageCallback = StreamlineLogCallback;  // Also forward to debug output
#else
      pref.showConsole = false;
      pref.logLevel = sl::LogLevel::eDefault;
      pref.logMessageCallback = nullptr;
#endif
      pref.pathsToPlugins = nullptr;
      pref.numPathsToPlugins = 0;
      pref.pathToLogsAndData = nullptr;
      // Application ID would be provided by NVIDIA for production use
      // For now, use 0 which may limit some functionality
      pref.applicationId = 0;
      pref.engine = sl::EngineType::eCustom;
      pref.engineVersion = nullptr;
      pref.projectId = nullptr;
      pref.renderAPI = sl::RenderAPI::eD3D11; // We're injecting into a DX11 game

      // CRITICAL: Use manual hooking mode because we're loading as a ReShade addon
      // AFTER the game has already created its D3D device and made D3D/DXGI calls.
      // With manual hooking, slInit can be called after device creation.
      // We will then use slSetD3DDevice() and slUpgradeInterface() to integrate.
      // 
      // eUseFrameBasedResourceTagging is required to use slSetTagForFrame (the non-deprecated API)
      pref.flags = sl::PreferenceFlags::eUseManualHooking 
                 | sl::PreferenceFlags::eDisableCLStateTracking
                 | sl::PreferenceFlags::eUseFrameBasedResourceTagging
                 | sl::PreferenceFlags::eUseDXGIFactoryProxy;

      // Request DLSS-G, Reflex, and PCL features
      sl::Feature features[] = { sl::kFeatureDLSS_G, sl::kFeatureReflex, sl::kFeaturePCL };
      pref.featuresToLoad = features;
      pref.numFeaturesToLoad = _countof(features);

      // Attempt initialization
      init_result = slInit(pref);
      init_succeeded = (init_result == sl::Result::eOk);

      if (init_succeeded)
      {
         OutputDebugStringA("[DLSS-G] Streamline SDK initialized successfully with manual hooking mode\n");
      }
      else
      {
         char buffer[256];
         sprintf_s(buffer, "[DLSS-G] Streamline SDK init failed with result: %d\n", (int)init_result);
         OutputDebugStringA(buffer);
      }

      return init_succeeded;
   }

   void StreamlineState::Shutdown()
   {
      if (init_succeeded)
      {
         slShutdown();
         init_succeeded = false;
      }
      init_attempted = false;
      init_result = sl::Result::eErrorNotInitialized;
      current_device = nullptr;
      upgraded_swapchains.clear();
   }

   void StreamlineState::OnDeviceDestroyed(void* device)
   {
      // If the destroyed device is the one Streamline knows about, clear our tracking
      // but don't shutdown Streamline - it will be reconfigured with the new device
      if (current_device == device)
      {
         OutputDebugStringA("[DLSS-G] Device destroyed - clearing Streamline device reference\n");
         current_device = nullptr;
         // Clear swapchain tracking as they're likely invalidated with the device
         upgraded_swapchains.clear();
      }
   }

   sl::Result StreamlineState::SetDevice(void* device)
   {
      if (!init_succeeded || !device)
         return sl::Result::eErrorNotInitialized;

      // If we already set this device, don't call again
      if (current_device == device)
      {
         OutputDebugStringA("[DLSS-G] slSetD3DDevice skipped - same device already set\n");
         return sl::Result::eOk;
      }

      // If a different device was previously set, log a warning
      // In manual hooking mode, we can call slSetD3DDevice with a new device
      if (current_device != nullptr)
      {
         char buffer[256];
         sprintf_s(buffer, "[DLSS-G] Device changed from %p to %p - updating Streamline\n", current_device, device);
         OutputDebugStringA(buffer);
      }

      sl::Result result = slSetD3DDevice(device);
      if (result == sl::Result::eOk)
      {
         current_device = device;
         char buffer[256];
         sprintf_s(buffer, "[DLSS-G] slSetD3DDevice succeeded for device %p\n", device);
         OutputDebugStringA(buffer);
      }
      else
      {
         char buffer[256];
         sprintf_s(buffer, "[DLSS-G] slSetD3DDevice FAILED for device %p with result: %d\n", device, (int)result);
         OutputDebugStringA(buffer);
      }

      return result;
   }

   bool StreamlineState::IsFeatureSupported(sl::Feature feature, IDXGIAdapter* adapter)
   {
      if (!init_succeeded)
         return false;

      sl::AdapterInfo adapterInfo{};
      if (adapter)
      {
         DXGI_ADAPTER_DESC desc;
         if (SUCCEEDED(adapter->GetDesc(&desc)))
         {
            adapterInfo.deviceLUID = (uint8_t*)&desc.AdapterLuid;
            adapterInfo.deviceLUIDSizeInBytes = sizeof(LUID);
         }
      }

      sl::Result result = slIsFeatureSupported(feature, adapterInfo);
      return (result == sl::Result::eOk);
   }

   IDXGISwapChain* StreamlineState::UpgradeSwapchain(IDXGISwapChain* swapchain)
   {
      if (!init_succeeded || !swapchain)
         return swapchain;

      // Check if already upgraded
      if (upgraded_swapchains.count(swapchain) > 0)
         return swapchain;

      char buffer[512];
      sprintf_s(buffer, "[DLSS-G] UpgradeSwapchain called with swapchain=%p\n", swapchain);
      OutputDebugStringA(buffer);

      // In manual hooking mode, we need to upgrade interfaces to SL proxies
      // so that Streamline can intercept Present calls for DLSS-G
      void* proxy = swapchain;
      sl::Result result = slUpgradeInterface(&proxy);

      IDXGISwapChain* proxySwapchain = static_cast<IDXGISwapChain*>(proxy);
      bool pointer_changed = (proxySwapchain != swapchain);

      sprintf_s(buffer, "[DLSS-G] slUpgradeInterface result=%d, original=%p, proxy=%p, pointer_changed=%s\n",
         (int)result, swapchain, proxy, pointer_changed ? "YES" : "NO");
      OutputDebugStringA(buffer);

      if (result == sl::Result::eOk)
      {
         // Track both the original and proxy
         upgraded_swapchains.insert(swapchain);
         if (pointer_changed)
            upgraded_swapchains.insert(proxySwapchain);
         
         if (pointer_changed)
         {
            OutputDebugStringA("[DLSS-G] Swapchain upgraded - PROXY IS DIFFERENT (wrapper created)\n");
            OutputDebugStringA("[DLSS-G] This means we MUST call Present on the proxy for Streamline to intercept!\n");
         }
         else
         {
            OutputDebugStringA("[DLSS-G] Swapchain upgraded - SAME POINTER (vtable hooks installed)\n");
            OutputDebugStringA("[DLSS-G] This means native Present should be intercepted automatically\n");
         }
         return proxySwapchain;
      }
      else
      {
         // Upgrade failed or wasn't needed
         upgraded_swapchains.insert(swapchain);
         
         sprintf_s(buffer, "[DLSS-G] slUpgradeInterface FAILED with result: %d\n", (int)result);
         OutputDebugStringA(buffer);
         return swapchain;
      }
   }

   // ============================================================================
   // DLSS_G Implementation
   // ============================================================================

   bool DLSS_G::HasInit(const FG::InstanceData* data) const
   {
      if (!data)
         return false;
      const auto* dlss_g_data = static_cast<const DLSS_G_InstanceData*>(data);
      return dlss_g_data->streamline_available && dlss_g_data->is_initialized;
   }

   bool DLSS_G::IsSupported(const FG::InstanceData* data) const
   {
      if (!data)
         return false;
      return data->is_supported;
   }

   bool DLSS_G::Init(FG::InstanceData*& data, ID3D11Device* device, FG::FrameGenerationContext* context, IDXGIAdapter* adapter)
   {
      if (!device)
         return false;

      // Create instance data
      auto* dlss_g_data = new DLSS_G_InstanceData();
      data = dlss_g_data;
      dlss_g_data->is_initialized = false;
      dlss_g_data->is_supported = false;
      dlss_g_data->streamline_available = false;

      // Attempt Streamline initialization (should already be done in OnCreateDevice, but try again just in case)
      auto& sl_state = StreamlineState::Get();
      if (!sl_state.TryInit() && !sl_state.init_succeeded)
      {
         // Streamline init failed - FSR-FG will be used as fallback
         return false;
      }

      // DLSS-G uses Streamline's internal DX12 interop - we do NOT create our own DX12 device.
      // Streamline intercepts the game's D3D calls and handles everything internally.
      // We just need to tell Streamline about the D3D11 device.
      // Use SetDevice() to properly track device changes across recreations.
      sl::Result result = sl_state.SetDevice(device);
      if (result != sl::Result::eOk)
      {
         return false;
      }

      // Check if DLSS-G feature is supported on this adapter
      if (!sl_state.IsFeatureSupported(sl::kFeatureDLSS_G, adapter))
      {
         dlss_g_data->is_supported = false;
         return false;
      }

      dlss_g_data->streamline_available = true;
      dlss_g_data->is_supported = true;

      // Check Reflex availability (required for proper frame pacing)
      dlss_g_data->reflex_available = sl_state.IsFeatureSupported(sl::kFeatureReflex, adapter);

      // Query DLSS-G capabilities
      sl::DLSSGState state{};
      result = slDLSSGGetState(dlss_g_data->viewport_handle, state, nullptr);
      if (result == sl::Result::eOk)
      {
         dlss_g_data->num_frames_to_generate_max = state.numFramesToGenerateMax;
         dlss_g_data->max_frame_multiplier = state.numFramesToGenerateMax;
      }
      else
      {
         dlss_g_data->num_frames_to_generate_max = 1;
         dlss_g_data->max_frame_multiplier = 1;
      }

      // Initialize viewport handle (using viewport ID 0 for single-viewport)
      dlss_g_data->viewport_handle.next = nullptr;

      // Mark feature capabilities
      dlss_g_data->supports_ui_composition = true;
      dlss_g_data->supports_async_compute = false;
      dlss_g_data->requires_hud_less_input = true;

      dlss_g_data->is_initialized = true;

      return true;
   }

   void DLSS_G::Deinit(FG::InstanceData*& data)
   {
      if (!data)
         return;

      auto* dlss_g_data = static_cast<DLSS_G_InstanceData*>(data);

      // Turn off DLSS-G before cleanup
      if (dlss_g_data->current_mode != sl::DLSSGMode::eOff)
      {
         sl::DLSSGOptions options{};
         options.mode = sl::DLSSGMode::eOff;
         slDLSSGSetOptions(dlss_g_data->viewport_handle, options);
      }

      // Free DLSS-G resources
      if (dlss_g_data->streamline_available)
      {
         slFreeResources(sl::kFeatureDLSS_G, dlss_g_data->viewport_handle);
      }

      delete dlss_g_data;
      data = nullptr;
   }

   bool DLSS_G::UpdateSettings(FG::InstanceData* data, ID3D11DeviceContext* command_list, const FG::SettingsData& settings_data)
   {
      if (!data || !data->is_initialized)
         return false;

      auto* dlss_g_data = static_cast<DLSS_G_InstanceData*>(data);

      if (!dlss_g_data->streamline_available)
         return false;

      // Store settings
      data->settings_data = settings_data;

      // Update DLSS-G options
      sl::DLSSGOptions options{};
      options.mode = settings_data.enable ? sl::DLSSGMode::eOn : sl::DLSSGMode::eOff;

      // Set frame multiplier (clamped to device max)
      options.numFramesToGenerate = (settings_data.frame_multiplier > 0)
         ? (std::min)(settings_data.frame_multiplier, dlss_g_data->num_frames_to_generate_max)
         : 1;

      // Keep resources when off for faster re-enable
      options.flags = sl::DLSSGFlags::eRetainResourcesWhenOff;

      // Enable fullscreen menu detection if UI composition is available
      if (settings_data.has_ui_composition)
      {
         options.flags = options.flags | sl::DLSSGFlags::eEnableFullscreenMenuDetection;
      }

      sl::Result result = slDLSSGSetOptions(dlss_g_data->viewport_handle, options);
      if (result == sl::Result::eOk)
      {
         dlss_g_data->current_mode = options.mode;
         return true;
      }

      return false;
   }

   void DLSS_G::SetReflexMarker(FG::InstanceData* data, sl::PCLMarker marker)
   {
      if (!data)
         return;

      auto* dlss_g_data = static_cast<DLSS_G_InstanceData*>(data);
      if (!dlss_g_data->reflex_available)
         return;

      uint32_t frame_idx = static_cast<uint32_t>(dlss_g_data->frame_index);
      sl::FrameToken* frameToken = nullptr;
      slGetNewFrameToken(frameToken, &frame_idx);

      if (frameToken)
         slPCLSetMarker(marker, *frameToken);
   }

   bool DLSS_G::Dispatch(FG::InstanceData* data, ID3D11DeviceContext* command_list, const FG::DispatchData& dispatch_data)
   {
      if (!data || !data->is_initialized || !command_list)
         return false;

      auto* dlss_g_data = static_cast<DLSS_G_InstanceData*>(data);

      if (!dlss_g_data->streamline_available)
         return false;

      if (dlss_g_data->current_mode == sl::DLSSGMode::eOff)
         return true; // Not an error, just disabled

      // Increment frame index
      dlss_g_data->frame_index++;

      // Get frame token for this frame
      uint32_t frame_idx = static_cast<uint32_t>(dlss_g_data->frame_index);
      sl::FrameToken* frameToken = nullptr;
      slGetNewFrameToken(frameToken, &frame_idx);

      if (!frameToken)
         return false;

      // Set PCL simulation start marker
      if (dlss_g_data->reflex_available)
      {
         slPCLSetMarker(sl::PCLMarker::eSimulationStart, *frameToken);
      }

      // Set common constants for this frame
      sl::Constants constants{};
      constants.jitterOffset.x = dispatch_data.jitter_x;
      constants.jitterOffset.y = dispatch_data.jitter_y;
      constants.depthInverted = data->settings_data.depth_inverted ? sl::Boolean::eTrue : sl::Boolean::eFalse;
      constants.cameraMotionIncluded = sl::Boolean::eTrue;
      constants.motionVectors3D = sl::Boolean::eFalse;
      constants.mvecScale.x = dispatch_data.mvs_x_scale;
      constants.mvecScale.y = dispatch_data.mvs_y_scale;
      constants.reset = dispatch_data.reset ? sl::Boolean::eTrue : sl::Boolean::eFalse;
      constants.cameraNear = dispatch_data.near_plane;
      constants.cameraFar = dispatch_data.far_plane;
      constants.cameraFOV = dispatch_data.fov;

      sl::Result result = slSetConstants(constants, *frameToken, dlss_g_data->viewport_handle);
      if (result != sl::Result::eOk)
      {
         return false;
      }

      // Tag resources for DLSS-G
      // For D3D11, resource state is NOT mandatory per sl_core_types.h documentation:
      // "Resource state is MANDATORY unless using D3D11"
      // Streamline handles the DX11-on-DX12 interop internally when we set renderAPI to eD3D11.

      // Tag depth buffer
      // Note: For D3D11, resource state should be 0 (D3D12_RESOURCE_STATE_COMMON)
      if (dispatch_data.depth)
      {
         sl::Resource depth_resource(sl::ResourceType::eTex2d, dispatch_data.depth, 0);

         sl::ResourceTag depth_tag(&depth_resource, sl::kBufferTypeDepth, sl::ResourceLifecycle::eValidUntilPresent);

         result = slSetTagForFrame(*frameToken, dlss_g_data->viewport_handle, &depth_tag, 1, nullptr);
      }

      // Tag motion vectors
      if (dispatch_data.motion_vectors)
      {
         sl::Resource mvec_resource(sl::ResourceType::eTex2d, dispatch_data.motion_vectors, 0);

         sl::ResourceTag mvec_tag(&mvec_resource, sl::kBufferTypeMotionVectors, sl::ResourceLifecycle::eValidUntilPresent);

         result = slSetTagForFrame(*frameToken, dlss_g_data->viewport_handle, &mvec_tag, 1, nullptr);
      }

      // Tag HUDless color (preferred for best quality)
      if (dispatch_data.hud_less_color)
      {
         sl::Resource hudless_resource(sl::ResourceType::eTex2d, dispatch_data.hud_less_color, 0);

         sl::ResourceTag hudless_tag(&hudless_resource, sl::kBufferTypeHUDLessColor, sl::ResourceLifecycle::eValidUntilPresent);

         result = slSetTagForFrame(*frameToken, dlss_g_data->viewport_handle, &hudless_tag, 1, nullptr);
      }

      // Tag UI color (if available)
      if (dispatch_data.ui_color)
      {
         sl::Resource ui_resource(sl::ResourceType::eTex2d, dispatch_data.ui_color, 0);

         sl::ResourceTag ui_tag(&ui_resource, sl::kBufferTypeUIColorAndAlpha, sl::ResourceLifecycle::eValidUntilPresent);

         result = slSetTagForFrame(*frameToken, dlss_g_data->viewport_handle, &ui_tag, 1, nullptr);
      }

      // Set PCL render submit start marker
      if (dlss_g_data->reflex_available)
      {
         slPCLSetMarker(sl::PCLMarker::eRenderSubmitStart, *frameToken);
      }

      return true;
   }

   void DLSS_G::OnPresentBegin(FG::InstanceData* data, IDXGISwapChain* swapchain)
   {
      if (!data || !swapchain)
         return;

      auto* dlss_g_data = static_cast<DLSS_G_InstanceData*>(data);

      if (!dlss_g_data->streamline_available)
         return;

      // In manual hooking mode, we need to upgrade the swapchain to SL proxy
      // so that Streamline can intercept Present calls for DLSS-G frame generation.
      // This only needs to happen once per swapchain.
      auto& sl_state = StreamlineState::Get();
      
      // Upgrade and store the proxy swapchain
      void* proxy = swapchain;
      sl::Result upgrade_result = sl::Result::eOk;
      
      if (dlss_g_data->proxy_swapchain == nullptr)
      {
         IDXGISwapChain* upgraded = sl_state.UpgradeSwapchain(swapchain);
         dlss_g_data->proxy_swapchain = upgraded;
         dlss_g_data->proxy_is_different = (upgraded != swapchain);
         
         char buffer[256];
         sprintf_s(buffer, "[DLSS-G] OnPresentBegin: proxy=%p, original=%p, different=%s\n",
            dlss_g_data->proxy_swapchain, swapchain, dlss_g_data->proxy_is_different ? "YES" : "NO");
         OutputDebugStringA(buffer);
      }

#if DLSS_G_PROXY_PRESENT_MODE == 1
      // Mode 1: Always call proxy->Present() explicitly
      if (dlss_g_data->proxy_swapchain)
      {
         OutputDebugStringA("[DLSS-G] Mode 1: Calling proxy->Present(0, 0) before native Present\n");
         HRESULT hr = dlss_g_data->proxy_swapchain->Present(0, 0);
         char buffer[128];
         sprintf_s(buffer, "[DLSS-G] Proxy Present returned: 0x%08X\n", hr);
         OutputDebugStringA(buffer);
      }
#elif DLSS_G_PROXY_PRESENT_MODE == 2
      // Mode 2: Only call proxy->Present() if proxy is a wrapper (different pointer)
      if (dlss_g_data->proxy_swapchain && dlss_g_data->proxy_is_different)
      {
         OutputDebugStringA("[DLSS-G] Mode 2: Proxy is wrapper - calling proxy->Present(0, 0)\n");
         HRESULT hr = dlss_g_data->proxy_swapchain->Present(0, 0);
         char buffer[128];
         sprintf_s(buffer, "[DLSS-G] Proxy Present returned: 0x%08X\n", hr);
         OutputDebugStringA(buffer);
      }
#else
      // Mode 0: Do nothing extra, assume slUpgradeInterface hooks the vtable
      // Native Present should be intercepted automatically
#endif

      if (!dlss_g_data->reflex_available)
         return;

      // Set PCL present start marker
      uint32_t frame_idx = static_cast<uint32_t>(dlss_g_data->frame_index);
      sl::FrameToken* frameToken = nullptr;
      slGetNewFrameToken(frameToken, &frame_idx);
      if (frameToken)
         slPCLSetMarker(sl::PCLMarker::ePresentStart, *frameToken);
   }

   void DLSS_G::OnPresentEnd(FG::InstanceData* data, IDXGISwapChain* swapchain)
   {
      if (!data)
         return;

      auto* dlss_g_data = static_cast<DLSS_G_InstanceData*>(data);

      if (!dlss_g_data->streamline_available || !dlss_g_data->reflex_available)
         return;

      // Set PCL present/submit end markers
      uint32_t frame_idx = static_cast<uint32_t>(dlss_g_data->frame_index);
      sl::FrameToken* frameToken = nullptr;
      slGetNewFrameToken(frameToken, &frame_idx);
      if (frameToken)
      {
         slPCLSetMarker(sl::PCLMarker::ePresentEnd, *frameToken);
         slPCLSetMarker(sl::PCLMarker::eRenderSubmitEnd, *frameToken);
         slPCLSetMarker(sl::PCLMarker::eSimulationEnd, *frameToken);
      }
   }

} // namespace NGX

#endif // ENABLE_DLSS_G
