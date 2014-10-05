; Luismark Loader: Loads executables and DLLs instantly.
; ATTENTION: Huge import trees may cause extensive recursion.
; 10x faster and 100x smaller than ntdll.dll version 6.1

; So, load the file like a raw binary at 0x7CFE0000 in a file called "win71.dll"

; Syscall numbers for Windows 7 x64:
 
; 0x000C: ZwClose
; 0x0016: ZwQueryInformationProcess
; 0x0025: ZwMapViewOfSection
; 0x0029: ZwTerminateProcess

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

; A macro for getting rid of the -0x7CFE0000 inside addressing brackets
%define RVA(x) x - 0x7CFE0000

; The entry point for the loader is at the EntryPoint label.
global EntryPoint

EntryPoint:
jmp LoadPEFile

GetModuleBase:
