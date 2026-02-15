#pragma once

#include "globals.h"

#include <Windows.h>
#include <string>
#include <fstream>

#if TEST
#include <DbgHelp.h>
#include <sstream>
#include <ctime>
#include <filesystem>
#pragma comment(lib, "DbgHelp.lib")
#endif // TEST

// DEFINE_NAME_AS_STRING
#ifndef _STRINGIZE // Already defined by some MSVC includes
#define _STRINGIZE(x) _STRINGIZE2(x)
#endif
// DEFINE_VALUE_AS_STRING
#define _STRINGIZE2(x) #x

#if DEVELOPMENT || TEST
#define PUBLISHING_CONSTEXPR
#else
#define PUBLISHING_CONSTEXPR constexpr
#endif

// In non debug builds, replace asserts with a message box
#if defined(NDEBUG) && (DEVELOPMENT || TEST)
#define ASSERT(expression) ((void)(                                                       \
            (!!(expression)) ||                                                           \
            (MessageBoxA(NULL, "Assertion failed: " #expression "\nFile: " __FILE__ "\nLine: " _STRINGIZE(__LINE__), Globals::MOD_NAME, MB_SETFOREGROUND | MB_OK))) \
        )
#undef assert
#define assert(expression) ASSERT(expression)
#else
#define ASSERT(expression) assert(expression)
#endif

#if DEVELOPMENT || TEST || _DEBUG
// "do while" is to avoid some edge cases with indentation
#define ASSERT_MSG(expression, msg)                                     \
    do {                                                                \
        if (!(expression)) {                                            \
            std::string full_msg = std::string("Assertion failed:\n\n") \
                + #expression + "\n\n"                                  \
                + msg + "\n\n"                                          \
                + "File: " + __FILE__ + "\n"                            \
                + "Line: " + std::to_string(__LINE__) + "\n\n"          \
                + "Press Yes to break into debugger.\n"                 \
                + "Press No to continue.";                              \
                                                                        \
            int result = MessageBoxA(nullptr,                           \
                full_msg.c_str(),                                       \
                "Assertion Failed",                                     \
                MB_ICONERROR | MB_YESNO);                               \
                                                                        \
            if (result == IDYES) { __debugbreak(); }                    \
        }                                                               \
    } while (false)
#define ASSERT_MSGF(expression, fmt, ...)                                     \
   do                                                                         \
   {                                                                          \
      char assert_buffer[512];                                                \
      std::snprintf(assert_buffer, sizeof(assert_buffer), fmt, __VA_ARGS__);  \
      ASSERT_MSG(expression, assert_buffer);                                  \
   } while (false)
#define ASSERT_ONCE(expression) do { { static bool asserted_once = false; \
if (!asserted_once && !(expression)) { ASSERT(expression); asserted_once = true; } } } while (false)
#define ASSERT_ONCE_MSG(expression, msg) do { { static bool asserted_once = false; \
if (!asserted_once && !(expression)) { ASSERT_MSG(expression, msg); asserted_once = true; } } } while (false)
#define ASSERT_ONCE_MSGF(expression, fmt, ...) do { { static bool asserted_once = false; \
if (!asserted_once && !(expression)) { ASSERT_MSGF(expression, fmt, __VA_ARGS__); asserted_once = true; } } } while (false)

#else
#define ASSERT_MSG(expression, msg) ((void)0)
#define ASSERT_ONCE(expression) ((void)0)
#define ASSERT_ONCE_MSG(expression, msg) ((void)0)
#endif

namespace
{
#if DEVELOPMENT || _DEBUG
   // Returns true if it vaguely succeeded (definition of success is unclear)
   bool LaunchDebugger(const char* name, const DWORD unique_random_handle = 0)
   {
#if 0 // Non stopping optional debugger
      // Get System directory, typically c:\windows\system32
      std::wstring systemDir(MAX_PATH + 1, '\0');
      UINT nChars = GetSystemDirectoryW(&systemDir[0], systemDir.length());
      if (nChars == 0) return false; // failed to get system directory
      systemDir.resize(nChars);

      // Get process ID and create the command line
      DWORD pid = GetCurrentProcessId();
      std::wostringstream s;
      s << systemDir << L"\\vsjitdebugger.exe -p " << pid;
      std::wstring cmdLine = s.str();

      // Start debugger process
      STARTUPINFOW si;
      ZeroMemory(&si, sizeof(si));
      si.cb = sizeof(si);

      PROCESS_INFORMATION pi;
      ZeroMemory(&pi, sizeof(pi));

      if (!CreateProcessW(NULL, &cmdLine[0], NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi)) return false;

      // Close debugger process handles to eliminate resource leak
      CloseHandle(pi.hThread);
      CloseHandle(pi.hProcess);
#else // Stop execution until the debugger is attached or skipped

#if 1
		// Note: the process ID is unique within a session, but not across sessions so it could repeat itself (though unlikely), we currently have no better solution to have a unique identifier unique across dll loads and process runs
		DWORD hProcessId = unique_random_handle != 0 ? unique_random_handle : GetCurrentProcessId();
      std::ifstream fileRead("Luma-Debug-Cache"); // Implies "Globals::MOD_NAME"
      if (fileRead)
      {
         DWORD hProcessIdRead;
         fileRead >> hProcessIdRead;
         fileRead.close();
         if (hProcessIdRead == hProcessId)
         {
            return true;
         }
      }

      if (!IsDebuggerPresent())
      {
			// TODO: Add a way to skip this dialog for x minutes or until we change compilation mode. Maybe we should only show it if the build was made with debug symbols/information, however there's no way to know at runtime AFAIK
			auto ret = MessageBoxA(NULL, "Loaded. You can now attach the debugger or continue execution (press \"Yes\").\nPress \"No\" to skip this message for this session.\nPress \"Cancel\" to close the application.", name, MB_SETFOREGROUND | MB_YESNOCANCEL);
         if (ret == IDABORT || ret == IDCANCEL)
         {
            exit(0);
         }
         // Write a file on disk so we can avoid re-opening the debugger dialog (which can be annoying) if a program loaded and unloaded multiple times in a row (it can happen on boot)
         // It'd be nice to delete this file when luma closes, but that's not possible as it closes many times.
         else if (ret == IDNO)
         {
            std::ofstream fileWrite("Luma-Debug-Cache"); // Implies "Globals::MOD_NAME"
            if (fileWrite)
            {
               fileWrite << hProcessId;
               fileWrite.close();
            }
         }
      }
#else
      // Wait for the debugger to attach
      while (!IsDebuggerPresent()) Sleep(100);
#endif

#endif

#if 0
      // Stop execution so the debugger can take over
      DebugBreak();
#endif

      return true;
   }
#endif // DEVELOPMENT || _DEBUG
}

#if TEST
namespace CrashHandler
{
   // Writes the callstack from an exception context to a log file next to the module.
   inline LONG WINAPI UnhandledExceptionHandler(EXCEPTION_POINTERS* exception_info)
   {
      // Build output path: <module_dir>/Luma-CrashLog.txt
      wchar_t module_path[MAX_PATH]{};
      // Pass nullptr to get the path of the host .exe; the crash log lands beside it.
      GetModuleFileNameW(nullptr, module_path, MAX_PATH);
      std::filesystem::path log_path = std::filesystem::path(module_path).parent_path() / "Luma-CrashLog.txt";

      std::ofstream log_file(log_path, std::ios::app);
      if (!log_file) return EXCEPTION_CONTINUE_SEARCH;

      // Timestamp
      std::time_t now = std::time(nullptr);
      char time_buf[64]{};
      std::strftime(time_buf, sizeof(time_buf), "%Y-%m-%d %H:%M:%S", std::localtime(&now));

      log_file << "=== Luma Crash Dump (" << time_buf << ") ===\n";
      log_file << "Game: " << Globals::GAME_NAME << "\n";

      if (exception_info && exception_info->ExceptionRecord)
      {
         const auto& rec = *exception_info->ExceptionRecord;
         std::ostringstream oss;
         oss << std::hex << "Exception Code: 0x" << rec.ExceptionCode
             << "  Address: 0x" << reinterpret_cast<uintptr_t>(rec.ExceptionAddress);
         log_file << oss.str() << "\n";
      }

      // Walk the stack
      HANDLE process = GetCurrentProcess();
      HANDLE thread  = GetCurrentThread();
      SymSetOptions(SYMOPT_UNDNAME | SYMOPT_DEFERRED_LOADS | SYMOPT_LOAD_LINES);
      SymInitialize(process, nullptr, TRUE);

      CONTEXT ctx{};
      if (exception_info && exception_info->ContextRecord)
      {
         ctx = *exception_info->ContextRecord;
      }
      else
      {
         RtlCaptureContext(&ctx);
      }

      STACKFRAME64 frame{};
      DWORD machine_type = 0;
#ifdef _M_X64
      machine_type = IMAGE_FILE_MACHINE_AMD64;
      frame.AddrPC.Offset    = ctx.Rip;
      frame.AddrPC.Mode      = AddrModeFlat;
      frame.AddrFrame.Offset = ctx.Rbp;
      frame.AddrFrame.Mode   = AddrModeFlat;
      frame.AddrStack.Offset = ctx.Rsp;
      frame.AddrStack.Mode   = AddrModeFlat;
#elif defined(_M_IX86)
      machine_type = IMAGE_FILE_MACHINE_I386;
      frame.AddrPC.Offset    = ctx.Eip;
      frame.AddrPC.Mode      = AddrModeFlat;
      frame.AddrFrame.Offset = ctx.Ebp;
      frame.AddrFrame.Mode   = AddrModeFlat;
      frame.AddrStack.Offset = ctx.Esp;
      frame.AddrStack.Mode   = AddrModeFlat;
#endif

      log_file << "\nCallstack:\n";

      constexpr int max_frames = 64;
      for (int i = 0; i < max_frames; ++i)
      {
         if (!StackWalk64(machine_type, process, thread, &frame, &ctx,
                          nullptr, SymFunctionTableAccess64, SymGetModuleBase64, nullptr))
         {
            break;
         }
         if (frame.AddrPC.Offset == 0) break;

         // Resolve symbol name
         constexpr size_t sym_buf_size = sizeof(SYMBOL_INFO) + MAX_SYM_NAME * sizeof(TCHAR);
         alignas(SYMBOL_INFO) char sym_buffer[sym_buf_size]{};
         SYMBOL_INFO* symbol  = reinterpret_cast<SYMBOL_INFO*>(sym_buffer);
         symbol->SizeOfStruct = sizeof(SYMBOL_INFO);
         symbol->MaxNameLen   = MAX_SYM_NAME;

         DWORD64 displacement64 = 0;
         const bool has_symbol = SymFromAddr(process, frame.AddrPC.Offset, &displacement64, symbol);

         // Resolve source file & line
         IMAGEHLP_LINE64 line_info{};
         line_info.SizeOfStruct = sizeof(IMAGEHLP_LINE64);
         DWORD displacement32 = 0;
         const bool has_line = SymGetLineFromAddr64(process, frame.AddrPC.Offset, &displacement32, &line_info);

         // Resolve module name
         HMODULE frame_module = nullptr;
         GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                            reinterpret_cast<LPCSTR>(frame.AddrPC.Offset), &frame_module);
         char mod_name[MAX_PATH]{};
         if (frame_module) GetModuleFileNameA(frame_module, mod_name, MAX_PATH);
         const char* mod_short = strrchr(mod_name, '\\');
         mod_short = mod_short ? mod_short + 1 : mod_name;

         std::ostringstream entry;
         entry << "  [" << i << "] ";
         entry << std::hex << "0x" << frame.AddrPC.Offset << std::dec;
         if (has_symbol) entry << "  " << symbol->Name << "+0x" << std::hex << displacement64 << std::dec;
         if (mod_short[0]) entry << "  (" << mod_short << ")";
         if (has_line) entry << "  " << line_info.FileName << ":" << line_info.LineNumber;
         entry << "\n";

         log_file << entry.str();
      }

      SymCleanup(process);

      log_file << "\n" << std::flush;
      log_file.close();

      return EXCEPTION_CONTINUE_SEARCH;
   }

   // Call once during initialization to register the crash handler.
   inline void Install()
   {
      SetUnhandledExceptionFilter(UnhandledExceptionHandler);
   }
}
#endif // TEST

// A macro wraper for the assert macro.
// Example usage            : ensure(device->CreateTexture2D(&desc, nullptr, &tex), == S_OK);
// In debug it expands to   : assert(device->CreateTexture2D(&desc, nullptr, &tex) == S_OK);
// In release it expands to : device->CreateTexture2D(&desc, nullptr, &tex);
#ifndef _DEBUG
#define ensure(always_keep, discard_if_ndebug) always_keep
#else
#define ensure(always_keep, discard_if_ndebug) (assert(always_keep discard_if_ndebug))
#endif