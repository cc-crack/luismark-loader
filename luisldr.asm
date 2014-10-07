; Luismark Loader: Loads executables and DLLs instantly.
; ATTENTION: Huge import trees may cause extensive recursion.
; 10x faster and 100x smaller than ntdll.dll version 6.1

; So, load the file like a raw binary at 0x7CFE0000 in a file called "win71.dll"

; Syscall numbers for Windows 7 x64:
 
; 0x000C: ZwClose
; 0x0016: ZwQueryInformationProcess
; 0x0025: ZwMapViewOfSection
; 0x0027: ZwUnmapViewOfSection
; 0x0029: ZwTerminateProcess
; 0x0030: ZwOpenFile
; 0x0047: ZwCreateSection

; Search in the DLLs wow64.dll, wow64cpu.dll and wow64win.dll for the string "ntdll.dll"
; replacing it with "win71.dll" to substitute the loader.

; Relocations are definitely hard to code, because:
; A loader like this requires more than 4 KB to be relocated, so it's impossible on NASM.
; MASM is too complex.

; The code starts here.

section .text vstart=0x1000 start=0x1000

; For developers that are migrating from MASM

%idefine offset
%idefine ptr

; A macro for getting rid of relocations.
%define val(x) [eax + x - 0x7CFE0000]

; The entry point for the loader is at the EntryPoint label.
global EntryPoint

EntryPoint:
jmp LoadPEFile

GetModuleBase:

; Get the return address and clear its low word (the high word is always 0x7CFE (or another if it has been relocated)).
mov eax, [esp]
xor eax, eax
ret

; Align in a 16-byte boundary for the syscalls.

; The Windows 7 WOW64 syscalls
ZwClose:
mov eax, 0x000C
xor ecx, ecx
lea edx, [esp+4]
call dword [fs:0x00C0]
add esp, byte +4
ret 4

ZwOpenFile:
mov eax, 0x0030
xor ecx, ecx
lea edx, [esp+4]
call dword [fs:0x00C0]
add esp, byte +4
ret 24

ZwUnmapViewOfSection:
mov eax, 0x0027
xor ecx, ecx
lea edx, [esp+4]
call dword [fs:0x00C0]
add esp, byte +4
ret 8

ZwMapViewOfSection:
mov eax, 0x0025
xor ecx, ecx
lea edx, [esp+4]
call dword [fs:0x00C0]
add esp, 4
ret 0x0014
