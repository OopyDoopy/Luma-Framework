#pragma once

// DirectX 12 Interop Utilities
// Provides a context for running DX12 workloads (Frame Generation) from a DX11 application.

#if ENABLE_FG

#include <d3d11.h>
#include <d3d11_4.h>
#include <d3d11on12.h>
#include <d3d12.h>
#include <dxgi1_6.h>
#include <unordered_map>
#include <mutex>

#include "../includes/com_ptr.h"

// For ASSERT_ONCE and logging
#ifndef DEVELOPMENT
#define DEVELOPMENT 0
#endif

#pragma comment(lib, "d3d11.lib")
#pragma comment(lib, "d3d12.lib")
#pragma comment(lib, "dxgi.lib")

namespace FG
{
   // Helper to check if a DX11 resource was created with shareable flags
   inline bool IsResourceShareable(ID3D11Resource* resource)
   {
      if (!resource)
         return false;

      // Try to get as texture first (most common case for FG)
      ComPtr<ID3D11Texture2D> texture;
      if (SUCCEEDED(resource->QueryInterface(__uuidof(ID3D11Texture2D), reinterpret_cast<void**>(texture.put()))))
      {
         D3D11_TEXTURE2D_DESC desc;
         texture->GetDesc(&desc);
         // Check for SHARED_NTHANDLE (preferred) or legacy SHARED flag
         return (desc.MiscFlags & D3D11_RESOURCE_MISC_SHARED_NTHANDLE) ||
                (desc.MiscFlags & D3D11_RESOURCE_MISC_SHARED);
      }

      // Try as buffer (less common for FG but possible)
      ComPtr<ID3D11Buffer> buffer;
      if (SUCCEEDED(resource->QueryInterface(__uuidof(ID3D11Buffer), reinterpret_cast<void**>(buffer.put()))))
      {
         D3D11_BUFFER_DESC desc;
         buffer->GetDesc(&desc);
         return (desc.MiscFlags & D3D11_RESOURCE_MISC_SHARED_NTHANDLE) ||
                (desc.MiscFlags & D3D11_RESOURCE_MISC_SHARED);
      }

      return false;
   }

   // Helper to create a shareable DX11 texture for FG use
   // Game mods should use this when creating resources for FG
   inline HRESULT CreateSharedTexture2D(
      ID3D11Device* device,
      const D3D11_TEXTURE2D_DESC& base_desc,
      ID3D11Texture2D** out_texture,
      D3D11_SUBRESOURCE_DATA* initial_data = nullptr)
   {
      if (!device || !out_texture)
         return E_INVALIDARG;

      D3D11_TEXTURE2D_DESC desc = base_desc;
      // Add sharing flags required for DX12 interop
      desc.MiscFlags |= D3D11_RESOURCE_MISC_SHARED_NTHANDLE | D3D11_RESOURCE_MISC_SHARED_KEYEDMUTEX;

      return device->CreateTexture2D(&desc, initial_data, out_texture);
   }

   // Represents a DX12 resource created from a shared DX11 resource.
   struct SharedResource
   {
      ComPtr<ID3D12Resource> dx12_resource;
      HANDLE shared_handle = nullptr;
      D3D12_RESOURCE_STATES current_state = D3D12_RESOURCE_STATE_COMMON;
   };

   // Context for managing DX12 device, command queue, and shared resources.
   // This context is used by Frame Generation implementations that require DX12.
   class FrameGenerationContext
   {
   public:
      FrameGenerationContext() = default;
      ~FrameGenerationContext();

      // Initialize the DX12 context from an existing DX11 device.
      // Creates a DX12 device on the same adapter as the DX11 device.
      bool Init(ID3D11Device* dx11_device);

      // Cleanup all DX12 resources.
      void Deinit();

      // Share a DX11 resource with DX12.
      // The resource must have been created with D3D11_RESOURCE_MISC_SHARED_NTHANDLE | D3D11_RESOURCE_MISC_SHARED_KEYEDMUTEX
      // or D3D11_RESOURCE_MISC_SHARED.
      // If the DX11 resource wasn't created as shareable, this will fail.
      // Returns nullptr if sharing fails.
      ID3D12Resource* GetOrCreateSharedResource(ID3D11Resource* dx11_resource);

      // Wait for all DX12 work to complete. Call before releasing resources.
      void WaitForGPU();

      // Signal the fence and get a value to wait on.
      uint64_t SignalFence();

      // Wait on the DX11 side for DX12 work to complete (for a given fence value).
      bool WaitForFenceOnDX11(ID3D11DeviceContext* context, uint64_t fence_value);

      // Execute the command list. Call after recording FG commands.
      bool ExecuteCommandList();

      // Reset command allocator and list for recording new commands.
      bool ResetCommandList();

      // Getters
      ID3D12Device* GetDX12Device() const
      {
         return dx12_device_.get();
      }
      ID3D12CommandQueue* GetCommandQueue() const
      {
         return command_queue_.get();
      }
      ID3D12GraphicsCommandList* GetCommandList() const
      {
         return command_list_.get();
      }
      ID3D12Fence* GetFence() const
      {
         return fence_.get();
      }
      uint64_t GetCurrentFenceValue() const
      {
         return fence_value_;
      }

      bool IsInitialized() const
      {
         return initialized_;
      }

   private:
      bool CreateDevice(IDXGIAdapter* adapter);
      bool CreateCommandQueue();
      bool CreateFence();
      bool CreateCommandListAndAllocator();

      // DX11 references (non-owning, for interop)
      ID3D11Device* dx11_device_ = nullptr;
      ComPtr<ID3D11Device5> dx11_device5_;         // For fence interop
      ComPtr<ID3D11DeviceContext4> dx11_context4_; // For fence waiting

      // DX12 objects
      ComPtr<ID3D12Device> dx12_device_;
      ComPtr<ID3D12CommandQueue> command_queue_;
      ComPtr<ID3D12CommandAllocator> command_allocator_;
      ComPtr<ID3D12GraphicsCommandList> command_list_;
      ComPtr<ID3D12Fence> fence_;
      HANDLE fence_event_ = nullptr;
      uint64_t fence_value_ = 0;

      // Shared fence for DX11 <-> DX12 sync
      ComPtr<ID3D11Fence> dx11_fence_;
      ComPtr<ID3D12Fence> shared_fence_;
      HANDLE shared_fence_handle_ = nullptr;

      // Shared resources cache
      std::mutex shared_resources_mutex_;
      std::unordered_map<ID3D11Resource*, SharedResource> shared_resources_;

      bool initialized_ = false;
   };

   // Implementation
   // -----------------------------------

   inline FrameGenerationContext::~FrameGenerationContext()
   {
      Deinit();
   }

   inline bool FrameGenerationContext::Init(ID3D11Device* dx11_device)
   {
      if (initialized_ || !dx11_device)
         return false;

      dx11_device_ = dx11_device;

      // Get the adapter used by the DX11 device
      ComPtr<IDXGIDevice> dxgi_device;
      HRESULT hr = dx11_device->QueryInterface(__uuidof(IDXGIDevice), reinterpret_cast<void**>(dxgi_device.put()));
      if (FAILED(hr))
         return false;

      ComPtr<IDXGIAdapter> adapter;
      hr = dxgi_device->GetAdapter(adapter.put());
      if (FAILED(hr))
         return false;

      // Query for ID3D11Device5 (needed for fence sharing)
      hr = dx11_device->QueryInterface(__uuidof(ID3D11Device5), reinterpret_cast<void**>(dx11_device5_.put()));
      if (FAILED(hr))
      {
         // Older Windows version, fence sharing not supported
         return false;
      }

      // Get immediate context and query for ID3D11DeviceContext4
      ComPtr<ID3D11DeviceContext> context;
      dx11_device->GetImmediateContext(context.put());
      hr = context->QueryInterface(__uuidof(ID3D11DeviceContext4), reinterpret_cast<void**>(dx11_context4_.put()));
      if (FAILED(hr))
         return false;

      // Create DX12 device
      if (!CreateDevice(adapter.get()))
         return false;

      // Create command queue
      if (!CreateCommandQueue())
         return false;

      // Create fence for GPU synchronization
      if (!CreateFence())
         return false;

      // Create command allocator and list
      if (!CreateCommandListAndAllocator())
         return false;

      initialized_ = true;
      return true;
   }

   inline void FrameGenerationContext::Deinit()
   {
      if (!initialized_)
         return;

      WaitForGPU();

      // Clear shared resources
      {
         std::lock_guard<std::mutex> lock(shared_resources_mutex_);
         for (auto& pair : shared_resources_)
         {
            if (pair.second.shared_handle)
            {
               CloseHandle(pair.second.shared_handle);
            }
         }
         shared_resources_.clear();
      }

      if (shared_fence_handle_)
      {
         CloseHandle(shared_fence_handle_);
         shared_fence_handle_ = nullptr;
      }

      if (fence_event_)
      {
         CloseHandle(fence_event_);
         fence_event_ = nullptr;
      }

      command_list_.reset();
      command_allocator_.reset();
      fence_.reset();
      shared_fence_.reset();
      dx11_fence_.reset();
      command_queue_.reset();
      dx12_device_.reset();
      dx11_context4_.reset();
      dx11_device5_.reset();
      dx11_device_ = nullptr;

      initialized_ = false;
   }

   inline bool FrameGenerationContext::CreateDevice(IDXGIAdapter* adapter)
   {
      // Create DX12 device on the same adapter
      HRESULT hr = D3D12CreateDevice(
         adapter,
         D3D_FEATURE_LEVEL_12_0,
         __uuidof(ID3D12Device),
         reinterpret_cast<void**>(dx12_device_.put()));

      if (FAILED(hr))
      {
         // Try with a lower feature level
         hr = D3D12CreateDevice(
            adapter,
            D3D_FEATURE_LEVEL_11_1,
            __uuidof(ID3D12Device),
            reinterpret_cast<void**>(dx12_device_.put()));
      }

      return SUCCEEDED(hr);
   }

   inline bool FrameGenerationContext::CreateCommandQueue()
   {
      D3D12_COMMAND_QUEUE_DESC queue_desc = {};
      queue_desc.Flags = D3D12_COMMAND_QUEUE_FLAG_NONE;
      queue_desc.Type = D3D12_COMMAND_LIST_TYPE_DIRECT;

      HRESULT hr = dx12_device_->CreateCommandQueue(&queue_desc, __uuidof(ID3D12CommandQueue), reinterpret_cast<void**>(command_queue_.put()));
      return SUCCEEDED(hr);
   }

   inline bool FrameGenerationContext::CreateFence()
   {
      // Create DX12 fence
      HRESULT hr = dx12_device_->CreateFence(0, D3D12_FENCE_FLAG_SHARED, __uuidof(ID3D12Fence), reinterpret_cast<void**>(fence_.put()));
      if (FAILED(hr))
         return false;

      // Create event for CPU waiting
      fence_event_ = CreateEvent(nullptr, FALSE, FALSE, nullptr);
      if (!fence_event_)
         return false;

      // Create shared fence for DX11 <-> DX12 synchronization
      hr = dx12_device_->CreateFence(0, D3D12_FENCE_FLAG_SHARED, __uuidof(ID3D12Fence), reinterpret_cast<void**>(shared_fence_.put()));
      if (FAILED(hr))
         return false;

      // Create shared handle
      hr = dx12_device_->CreateSharedHandle(shared_fence_.get(), nullptr, GENERIC_ALL, nullptr, &shared_fence_handle_);
      if (FAILED(hr))
         return false;

      // Open the shared fence on DX11 side
      hr = dx11_device5_->OpenSharedFence(shared_fence_handle_, __uuidof(ID3D11Fence), reinterpret_cast<void**>(dx11_fence_.put()));
      if (FAILED(hr))
      {
         CloseHandle(shared_fence_handle_);
         shared_fence_handle_ = nullptr;
         return false;
      }

      return true;
   }

   inline bool FrameGenerationContext::CreateCommandListAndAllocator()
   {
      HRESULT hr = dx12_device_->CreateCommandAllocator(
         D3D12_COMMAND_LIST_TYPE_DIRECT,
         __uuidof(ID3D12CommandAllocator),
         reinterpret_cast<void**>(command_allocator_.put()));
      if (FAILED(hr))
         return false;

      hr = dx12_device_->CreateCommandList(
         0,
         D3D12_COMMAND_LIST_TYPE_DIRECT,
         command_allocator_.get(),
         nullptr, // No initial pipeline state
         __uuidof(ID3D12GraphicsCommandList),
         reinterpret_cast<void**>(command_list_.put()));
      if (FAILED(hr))
         return false;

      // Close the command list (it starts in recording state)
      hr = command_list_->Close();
      return SUCCEEDED(hr);
   }

   inline ID3D12Resource* FrameGenerationContext::GetOrCreateSharedResource(ID3D11Resource* dx11_resource)
   {
      if (!dx11_resource || !initialized_)
         return nullptr;

      // Validate that resource was created with sharing flags
      if (!IsResourceShareable(dx11_resource))
      {
#if DEVELOPMENT
         // In development builds, assert to notify developers
         // This is a programmer error - resources must be created with SHARED flags
         static bool s_warned_non_shareable = false;
         if (!s_warned_non_shareable)
         {
            s_warned_non_shareable = true;
            // ASSERT_ONCE equivalent - will trigger debugger break in debug builds
            __debugbreak();
         }
#endif
         // In release builds, log error via ReShade
         // Note: reshade::log::message would be called here if we had access to it
         // For now, we just return nullptr to fail gracefully
         return nullptr;
      }

      std::lock_guard<std::mutex> lock(shared_resources_mutex_);

      // Check cache
      auto it = shared_resources_.find(dx11_resource);
      if (it != shared_resources_.end())
         return it->second.dx12_resource.get();

      // Get shared handle from DX11 resource
      ComPtr<IDXGIResource1> dxgi_resource;
      HRESULT hr = dx11_resource->QueryInterface(__uuidof(IDXGIResource1), reinterpret_cast<void**>(dxgi_resource.put()));
      if (FAILED(hr))
         return nullptr;

      HANDLE shared_handle = nullptr;
      hr = dxgi_resource->CreateSharedHandle(
         nullptr,
         DXGI_SHARED_RESOURCE_READ | DXGI_SHARED_RESOURCE_WRITE,
         nullptr,
         &shared_handle);

      if (FAILED(hr) || !shared_handle)
         return nullptr;

      // Open shared handle on DX12 device
      ComPtr<ID3D12Resource> dx12_resource;
      hr = dx12_device_->OpenSharedHandle(shared_handle, __uuidof(ID3D12Resource), reinterpret_cast<void**>(dx12_resource.put()));
      if (FAILED(hr))
      {
         CloseHandle(shared_handle);
         return nullptr;
      }

      // Cache the shared resource
      SharedResource& shared = shared_resources_[dx11_resource];
      shared.dx12_resource = dx12_resource;
      shared.shared_handle = shared_handle;
      shared.current_state = D3D12_RESOURCE_STATE_COMMON;

      return dx12_resource.get();
   }

   inline void FrameGenerationContext::WaitForGPU()
   {
      if (!command_queue_ || !fence_)
         return;

      const uint64_t wait_value = ++fence_value_;
      HRESULT hr = command_queue_->Signal(fence_.get(), wait_value);
      if (FAILED(hr))
         return;

      if (fence_->GetCompletedValue() < wait_value)
      {
         hr = fence_->SetEventOnCompletion(wait_value, fence_event_);
         if (SUCCEEDED(hr))
         {
            WaitForSingleObject(fence_event_, INFINITE);
         }
      }
   }

   inline uint64_t FrameGenerationContext::SignalFence()
   {
      if (!command_queue_ || !shared_fence_)
         return 0;

      const uint64_t signal_value = ++fence_value_;
      command_queue_->Signal(shared_fence_.get(), signal_value);
      return signal_value;
   }

   inline bool FrameGenerationContext::WaitForFenceOnDX11(ID3D11DeviceContext* context, uint64_t fence_value)
   {
      if (!dx11_context4_ || !dx11_fence_)
         return false;

      HRESULT hr = dx11_context4_->Wait(dx11_fence_.get(), fence_value);
      return SUCCEEDED(hr);
   }

   inline bool FrameGenerationContext::ExecuteCommandList()
   {
      if (!command_list_ || !command_queue_)
         return false;

      // Close the command list
      HRESULT hr = command_list_->Close();
      if (FAILED(hr))
         return false;

      // Execute
      ID3D12CommandList* lists[] = {command_list_.get()};
      command_queue_->ExecuteCommandLists(1, lists);

      return true;
   }

   inline bool FrameGenerationContext::ResetCommandList()
   {
      if (!command_allocator_ || !command_list_)
         return false;

      HRESULT hr = command_allocator_->Reset();
      if (FAILED(hr))
         return false;

      hr = command_list_->Reset(command_allocator_.get(), nullptr);
      return SUCCEEDED(hr);
   }

} // namespace FG

#endif // ENABLE_FG
