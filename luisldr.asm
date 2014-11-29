; Luismark Loader code

ZwOpenFile:
mov eax, 0x0030
xor ecx, ecx
lea edx, [esp+4]
call dword [fs:0x00C0]
add esp, byte +4
ret 0x0020

ZwCreateSection:
mov eax, 0x0047
xor ecx, ecx
lea edx, [esp+4]
call dword [fs:0x00C0]
add esp, byte +4
ret 0x0024

ZwMapViewOfSection:
mov eax, 0x0025
xor ecx, ecx
lea edx, [esp+4]
call dword [fs:0x00C0]
add esp, byte +4
ret 0x0030

ZwUnmapViewOfSection:
mov eax, 0x0027
xor ecx, ecx
lea edx, [esp+4]
call dword [fs:0x00C0]
add esp, byte +4
ret 0x0008

ZwTerminateProcess:
mov eax, 0x0029
xor ecx, ecx
lea edx, [esp+4]
call dword [fs:0x00C0]
add esp, byte +4
ret 0x0008

ZwClose:
mov eax, 0x000C
xor ecx, ecx
lea edx, [esp+4]
call dword [fs:0x00C0]
add esp, byte +4
ret 0x0004

LoadPEFile:
push ebp
mov ebp, esp
and dword [ebp-0x3C], byte +0
and dword [ebp-0x30], byte +0
mov eax, [ebp+0x08]
mov dword [ebp-0x24], eax
mov dword [ebp-0x20], 1
and dword [ebp-0x1C], byte +0
mov dword [ebp-0x28], 24
and dword [ebp-0x18], byte +0
and dword [ebp-0x14], byte +0
and dword [ebp-0x38], byte +0
and dword [ebp-0x34], byte +0
push byte +0
push byte +0
lea eax, [ebp-0x38]
push eax
lea eax, [ebp-0x28]
push eax
push dword 0xE0000000
lea eax, [ebp-0x3C]
push eax
call ZwOpenFile
test eax, eax
jnz .L1
and dword [ebp-0x10], byte +0
mov dword [ebp-0x0C], 0x00100000
and dword [ebp-0x08], byte +0
push dword [ebp-0x3C]
push dword 0x01000000
push byte +0x40
lea eax, [ebp-0x0C]
push eax
push byte +0
push dword 0x10000000
lea eax, [ebp-0x10]
push eax
call ZwCreateSection
test eax, eax
jnz .L2
mov dword [ebp-0x04], 0x00100000
push dword [ebp+0x0C]
push byte +0
push byte +0x40
push byte +0
push byte +2
lea eax, [ebp-0x04]
push eax
lea eax, [esp-0x14]
push eax
push byte +0
push byte +0
push dword [ebp+0x0C]
push byte -1
push dword [ebp-0x10]
call ZwMapViewOfSection
test eax, eax
jnz .L3
mov eax, [ebp+0x0C]
mov eax, [eax+0x3C]
call dword [eax+0x2C]
mov [ebp-0x30], eax
push dword [ebp+0x0C]
push byte -1
call ZwUnmapViewOfSection
.L3:
push dword [ebp-0x10]
call ZwClose
.L2:
push dword [ebp-0x3C]
call ZwClose
.L1:
push dword [ebp-0x30]
push byte -1
call ZwTerminateProcess
mov eax, [ebp-0x30]
mov esp, ebp
pop ebp
ret 0x0008
