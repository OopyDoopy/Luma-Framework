#pragma once

// Frame Generation base interfaces
// Similar to super_resolution.h but for Frame Generation (DLSS-G, FSR Frame Generation)
//
// IMPORTANT: Game mods must create depth, motion vectors, and color resources with
// D3D11_RESOURCE_MISC_SHARED_NTHANDLE | D3D11_RESOURCE_MISC_SHARED_KEYEDMUTEX flags
// when ENABLE_FG is active, to allow DX11->DX12 resource sharing for frame generation.

// Forward declarations only - avoid including heavy headers
struct ID3D11Device;
struct ID3D11DeviceContext;
struct ID3D11Resource;
struct IDXGIAdapter;
struct IDXGISwapChain;

namespace FG
{
   // Note that these don't necessarily match 1:1 with classes, some might be different configurations of the same implementation.
   enum class UserType
   {
      None,
      Auto,
      DLSS_G, // NVIDIA DLSS Frame Generation (requires Streamline SDK)
      FSR_FG, // AMD FSR 3 Frame Generation (FidelityFX SDK)
   };

   // Put these in order of preference (most preferred first). For automatic selection.
   // DLSS-G is preferred when available (RTX 40+ series), FSR-FG as fallback.
   enum class Type
   {
      DLSS_G = 0, // Highest priority
      FSR_FG = 1,
      None = -1
   };

   // Helper to match user type to implementation type (similar to SR::AreTypesEqual)
   __forceinline bool AreTypesEqual(UserType user_type, Type type)
   {
      switch (user_type)
      {
      case UserType::None:
         return type == Type::None;
      case UserType::Auto:
         return true; // Accept first compatible implementation
      case UserType::DLSS_G:
         return type == Type::DLSS_G;
      case UserType::FSR_FG:
         return type == Type::FSR_FG;
      }
      return false;
   }

   // Forward declaration
   class FrameGenerationContext;

   struct SettingsData
   {
      // Resolution settings (usually matches swapchain)
      unsigned int output_width = 1;
      unsigned int output_height = 1;
      unsigned int render_width = 1;
      unsigned int render_height = 1;

      bool enable = false;
      bool reset_history = false;

      // Motion vector configuration (should match SR settings)
      bool depth_inverted = false;
      bool mvs_jittered = false;
      // MVs need positive values when moving towards top-left of screen
      float mvs_x_scale = 1.f; // Scale or flip by render res
      float mvs_y_scale = 1.f; // Scale or flip by render res

      // Frame generation multiplier (DLSS-G: 1-3, FSR-FG: 1 only)
      unsigned int frame_multiplier = 2;

      // UI Composition handling
      bool has_ui_composition = false; // Whether UI/HUDless buffers are provided

      bool operator==(const SettingsData& other) const
      {
         return (output_width == other.output_width) &&
                (output_height == other.output_height) &&
                (render_width == other.render_width) &&
                (render_height == other.render_height) &&
                (enable == other.enable) &&
                (reset_history == other.reset_history) &&
                (depth_inverted == other.depth_inverted) &&
                (mvs_jittered == other.mvs_jittered) &&
                (frame_multiplier == other.frame_multiplier) &&
                (has_ui_composition == other.has_ui_composition);
      }
   };

   struct DispatchData
   {
      bool reset = false;

      // DX11 Resources - must be created with SHARED flags for DX12 interop
      // These will be shared with DX12 internally
      ID3D11Resource* input_color = nullptr;    // Final rendered game color (after SR, before UI if possible)
      ID3D11Resource* depth = nullptr;          // Depth buffer (same as used for SR)
      ID3D11Resource* motion_vectors = nullptr; // Motion vectors (same as used for SR)
      ID3D11Resource* output_color = nullptr;   // Output buffer for interpolated frame (if not using swapchain directly)

      // Optional resources for advanced UI handling
      ID3D11Resource* ui_color = nullptr;       // Separate UI layer (premultiplied alpha, alpha=0 for non-UI)
      ID3D11Resource* hud_less_color = nullptr; // Color without HUD (for best quality)

      // Camera data (same as SR)
      float near_plane = 0.01f;
      float far_plane = 1000.f;
      float fov = 1.0f;          // Vertical FOV in radians
      float time_delta = 0.016f; // Frame time in seconds

      // Jitter (same as used for SR, in UV space -0.5 to 0.5)
      float jitter_x = 0.f;
      float jitter_y = 0.f;

      // Motion vector scale (to convert to [-1, 1] range)
      float mvs_x_scale = 1.f;
      float mvs_y_scale = 1.f;

      // Viewport / render dimensions for this frame
      unsigned int render_width = 0;
      unsigned int render_height = 0;

      // Frame index (for temporal algorithms, should match SR frame index)
      unsigned long long frame_index = 0;

      // Returns true if minimum required inputs are available
      bool HasRequiredInputs() const
      {
         return depth != nullptr && motion_vectors != nullptr && (input_color != nullptr || hud_less_color != nullptr);
      }
   };

   // Interface to be subclassed. Represents a handle/instance for a specific FG implementation.
   struct InstanceData
   {
      bool is_supported = false;
      bool is_initialized = false;

      // Capabilities
      bool supports_ui_composition = false;
      bool supports_async_compute = false;
      bool requires_hud_less_input = false;

      // Frame multiplier support
      unsigned int max_frame_multiplier = 1; // Max supported by this implementation

      // Current settings cache
      SettingsData settings_data = {};

      virtual ~InstanceData() = default;
   };

   // A Frame Generation implementation base class.
   // Subclassed by DLSS_G and FSR_FG implementations.
   class FrameGenerationImpl
   {
   public:
      virtual ~FrameGenerationImpl() = default;

      virtual bool HasInit(const InstanceData* data) const
      {
         return data && data->is_initialized;
      }
      // Needs Init to be called first
      virtual bool IsSupported(const InstanceData* data) const
      {
         return data && data->is_supported;
      }

      // Must be called once before usage. Still expects Deinit() to be called even if it failed.
      // Returns whether this FG implementation is supported by hardware and driver.
      // The context parameter provides the DX12 interop layer.
      virtual bool Init(InstanceData*& data, ID3D11Device* device, FrameGenerationContext* context, IDXGIAdapter* adapter = nullptr)
      {
         return false;
      }

      // Should be called before shutdown or on device destruction.
      virtual void Deinit(InstanceData*& data)
      {
      }

      // Note that this might expect the same command list all the times.
      // Returns true if the settings changed or were up to date.
      virtual bool UpdateSettings(InstanceData* data, ID3D11DeviceContext* command_list, const SettingsData& settings_data)
      {
         return false;
      }

      // Execute frame generation.
      // Returns true if frame generation succeeded.
      // Note: Frame generation typically hooks into Present and manages its own frame pacing.
      virtual bool Dispatch(InstanceData* data, ID3D11DeviceContext* command_list, const DispatchData& dispatch_data)
      {
         return false;
      }

      // Called at frame boundaries (around Present)
      // swapchain parameter allows access to swapchain for proxy management
      virtual void OnPresentBegin(InstanceData* data, IDXGISwapChain* swapchain = nullptr)
      {
      }
      virtual void OnPresentEnd(InstanceData* data, IDXGISwapChain* swapchain = nullptr)
      {
      }

      // Get the implementation name for UI display
      virtual const char* GetName() const { return "Unknown"; }

      // Get the implementation type
      virtual Type GetType() const { return Type::None; }
   };

} // namespace FG
