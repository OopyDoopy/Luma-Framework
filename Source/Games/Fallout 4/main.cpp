#define GAME_FALLOUT4 1

#define ENABLE_NGX 1

#include "..\..\Core\core.hpp"

// TODO: Fix this globaly? Define NOMINMAX before including windows.h.
#undef min
#undef max

namespace
{
    const ShaderHashesList shader_hashes_TAA = { .pixel_shaders = { 0x61CC29E6 } };

    // We only need jitters from it. They should be in [4] and [5].
    // 8 long Halton(2,3) sequence.
    void* g_cb_taa_mapped_data;
    float g_cb_taa_data[24];
}

struct GameDeviceDataFallout4 final : GameDeviceData
{
    ComPtr<ID3D11Texture2D> tex_dlss_output;
    ComPtr<ID3D11Buffer> cb_taa;
};

class GameFallout4 final : public Game
{
public:
   
    static GameDeviceDataFallout4& GetGameDeviceData(DeviceData& device_data)
    {
        return *(GameDeviceDataFallout4*)device_data.game;
    }

    void OnLoad(std::filesystem::path& file_path, bool failed) override
    {
        if (!failed)
        {
            reshade::register_event<reshade::addon_event::map_buffer_region>(GameFallout4::OnMapBufferRegion);
            reshade::register_event<reshade::addon_event::unmap_buffer_region>(GameFallout4::OnUnmapBufferRegion);
        }
    }

    void OnInit(bool async) override
    {
        luma_settings_cbuffer_index = 8;
        luma_data_cbuffer_index = 7;
    }

    void OnCreateDevice(ID3D11Device* native_device, DeviceData& device_data) override
    {
        device_data.game = new GameDeviceDataFallout4;
    }

    void OnInitSwapchain(reshade::api::swapchain* swapchain) override
    {
        auto& device_data = *swapchain->get_device()->get_private_data<DeviceData>();
        auto& game_device_data = GetGameDeviceData(device_data);

        game_device_data.tex_dlss_output.reset();
    }

    static void OnMapBufferRegion(reshade::api::device* device, reshade::api::resource resource, uint64_t offset, uint64_t size, reshade::api::map_access access, void** data)
    {
        auto& device_data = *device->get_private_data<DeviceData>();
        auto& game_device_data = GetGameDeviceData(device_data);

        auto buffer = (ID3D11Buffer*)resource.handle;
        if (buffer == game_device_data.cb_taa) {
            g_cb_taa_mapped_data = *data;
        }
    }

    static void OnUnmapBufferRegion(reshade::api::device* device, reshade::api::resource resource)
    {
        auto& device_data = *device->get_private_data<DeviceData>();
        auto& game_device_data = GetGameDeviceData(device_data);

        auto buffer = (ID3D11Buffer*)resource.handle;
        if (buffer == game_device_data.cb_taa) {
            std::memcpy(&g_cb_taa_data, g_cb_taa_mapped_data, sizeof(g_cb_taa_data));
        }
    }

    DrawOrDispatchOverrideType OnDrawOrDispatch(ID3D11Device* native_device, ID3D11DeviceContext* native_device_context, CommandListData& cmd_list_data, DeviceData& device_data, reshade::api::shader_stage stages, const ShaderHashesList<OneShaderPerPipeline>& original_shader_hashes, bool is_custom_pass, bool& updated_cbuffers, std::function<void()>* original_draw_dispatch_func) override
    {
        auto& game_device_data = GetGameDeviceData(device_data);

        if (original_shader_hashes.Contains(shader_hashes_TAA))
        {
            if (device_data.sr_type != SR::Type::None)
            {
                // Get the TAA CB. We need to track it later on map/unmap.
                native_device_context->PSGetConstantBuffers(2, 1, game_device_data.cb_taa.put());

                // DLSS requires an immediate context for execution!
                ASSERT_ONCE(native_device_context->GetType() == D3D11_DEVICE_CONTEXT_IMMEDIATE);

                auto* sr_instance_data = device_data.GetSRInstanceData();
                ASSERT_ONCE(sr_instance_data);

                SR::SettingsData settings_data;
                settings_data.output_width = device_data.output_resolution.x;
                settings_data.output_height = device_data.output_resolution.y;
                settings_data.render_width = device_data.render_resolution.x;
                settings_data.render_height = device_data.render_resolution.y;
                settings_data.dynamic_resolution = false;
                settings_data.hdr = false;
                settings_data.inverted_depth = false;
                settings_data.mvs_jittered = false;

                // MVs are in UV space so we need to scale them to screen space for DLSS.
                settings_data.mvs_x_scale = device_data.render_resolution.x;
                settings_data.mvs_y_scale = device_data.render_resolution.y;
                
                settings_data.render_preset = dlss_render_preset;
                settings_data.auto_exposure = false;

                sr_implementations[device_data.sr_type]->UpdateSettings(sr_instance_data, native_device_context, settings_data);

                // Get SRVs.
                ComPtr<ID3D11ShaderResourceView> srv_scene;
                native_device_context->PSGetShaderResources(0, 1, srv_scene.put());
                ComPtr<ID3D11ShaderResourceView> srv_mvs;
                native_device_context->PSGetShaderResources(2, 1, srv_mvs.put());
                ComPtr<ID3D11ShaderResourceView> srv_depth;
                native_device_context->PSGetShaderResources(3, 1, srv_depth.put());

                // Get resources from SRVs.
                ComPtr<ID3D11Resource> resource_scene;
                srv_scene->GetResource(resource_scene.put());
                ComPtr<ID3D11Resource> resource_mvs;
                srv_mvs->GetResource(resource_mvs.put());
                ComPtr<ID3D11Resource> resource_depth;
                srv_depth->GetResource(resource_depth.put());

                // Get RTVs.
                std::array<ID3D11RenderTargetView*, 2> rtvs;
                native_device_context->OMGetRenderTargets(rtvs.size(), rtvs.data(), nullptr);

                // RTV1 should be the current frame and the backbuffer.
                ComPtr<ID3D11Resource> resource_output;
                rtvs[1]->GetResource(resource_output.put());

                // Create the output resource for DLSS.
                [[unlikely]] if (!game_device_data.tex_dlss_output)
                {
                    ensure(resource_output->QueryInterface(game_device_data.tex_dlss_output.put()), >= 0);
                    D3D11_TEXTURE2D_DESC tex_desc;
                    game_device_data.tex_dlss_output->GetDesc(&tex_desc);
                    tex_desc.BindFlags = D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_UNORDERED_ACCESS;
                    ensure(native_device->CreateTexture2D(&tex_desc, nullptr, game_device_data.tex_dlss_output.put()), >= 0);
                }

                SR::SuperResolutionImpl::DrawData draw_data;
                draw_data.source_color = resource_scene.get();
                draw_data.output_color = game_device_data.tex_dlss_output.get();
                draw_data.motion_vectors = resource_mvs.get();
                draw_data.depth_buffer = resource_depth.get();

                // Jitters are in UV offsets so we need to scale them to pixel offsets for DLSS.
                draw_data.jitter_x = g_cb_taa_data[4] * device_data.render_resolution.x * 1.0f;
                draw_data.jitter_y = g_cb_taa_data[5] * device_data.render_resolution.y * -1.0f;

                draw_data.render_width = device_data.render_resolution.x;
                draw_data.render_height = device_data.render_resolution.y;

                sr_implementations[device_data.sr_type]->Draw(sr_instance_data, native_device_context, draw_data);

                // Copy DLSS output to the original TAA's current frame and the backbuffer.
                native_device_context->CopyResource(resource_output.get(), game_device_data.tex_dlss_output.get());

                auto release_com_array = [](auto& array){ for (auto* p : array) if (p) p->Release(); };
                release_com_array(rtvs);

                return DrawOrDispatchOverrideType::Replaced;
            }

            return DrawOrDispatchOverrideType::None;
        }

        return DrawOrDispatchOverrideType::None;
    }

    void OnPresent(ID3D11Device* native_device, DeviceData& device_data) override
    {
        auto& game_device_data = GetGameDeviceData(device_data);

        if (!custom_texture_mip_lod_bias_offset)
        {
            std::shared_lock shared_lock_samplers(s_mutex_samplers);
            if (device_data.sr_type != SR::Type::None && !device_data.sr_suppressed)
            {
               device_data.texture_mip_lod_bias_offset = SR::GetMipLODBias(device_data.render_resolution.y, device_data.output_resolution.y); // This results in -1 at output res
            }
            else
            {
               device_data.texture_mip_lod_bias_offset = 0.0f;
            }
        }
    }

    void PrintImGuiAbout() override
    {
        ImGui::Text("Fallout 4 Luma mod - about and credits section", "");
    }
};

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
    if (ul_reason_for_call == DLL_PROCESS_ATTACH)
    {
        Globals::SetGlobals(PROJECT_NAME, "Fallout 4 Luma mod");
        Globals::VERSION = 1;

        swapchain_format_upgrade_type  = TextureFormatUpgradesType::AllowedEnabled;
        swapchain_upgrade_type         = SwapchainUpgradeType::scRGB;
        texture_format_upgrades_type   = TextureFormatUpgradesType::AllowedEnabled;
        // ### Check which of these are needed and remove the rest ###
        texture_upgrade_formats = {
            reshade::api::format::r8g8b8a8_unorm,
            reshade::api::format::r8g8b8a8_unorm_srgb,
            reshade::api::format::r8g8b8a8_typeless,
            reshade::api::format::r8g8b8x8_unorm,
            reshade::api::format::r8g8b8x8_unorm_srgb,
            reshade::api::format::b8g8r8a8_unorm,
            reshade::api::format::b8g8r8a8_unorm_srgb,
            reshade::api::format::b8g8r8a8_typeless,
            reshade::api::format::b8g8r8x8_unorm,
            reshade::api::format::b8g8r8x8_unorm_srgb,
            reshade::api::format::b8g8r8x8_typeless,

            reshade::api::format::r11g11b10_float,
        };
        // ### Check these if textures are not upgraded ###
        texture_format_upgrades_2d_size_filters = 0 | (uint32_t)TextureFormatUpgrades2DSizeFilters::SwapchainResolution | (uint32_t)TextureFormatUpgrades2DSizeFilters::SwapchainAspectRatio;

        enable_samplers_upgrade = true;
        
        // TODO: Remove this later!
        Globals::DEVELOPMENT_STATE = Globals::ModDevelopmentState::WorkInProgress;

        #if DEVELOPMENT
        forced_shader_names.emplace(0x63EE533F, "Motion Blur");
        forced_shader_names.emplace(0x80802E60, "Tonemap");
        forced_shader_names.emplace(0x61CC29E6, "TAA");
        #endif

        game = new GameFallout4();
    }

    CoreMain(hModule, ul_reason_for_call, lpReserved);

    return TRUE;
}