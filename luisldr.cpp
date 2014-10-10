// Luismark Loader code

// Structures, macros and typedefs for ZwOpenFile (and itself)

#define NULL 0

typedef unsigned int DWORD;
typedef int HANDLE;
typedef HANDLE* PHANDLE;
typedef DWORD ACCESS_MASK;
typedef unsigned short wchar_t;
typedef wchar_t* PUNICODE_STRING;
typedef unsigned long ULONG;
typedef void* PVOID;
typedef struct _OBJECT_ATTRIBUTES {
    ULONG Length;
    HANDLE RootDirectory;
    PUNICODE_STRING ObjectName;
    ULONG Attributes;
    PVOID SecurityDescriptor;
    PVOID SecurityQualityOfService;
} OBJECT_ATTRIBUTES, *POBJECT_ATTRIBUTES;
typedef ULONG* ULONG_PTR;
typedef DWORD NTSTATUS;
typedef struct _IO_STATUS_BLOCK {
    NTSTATUS Status;
    ULONG_PTR Information;
} IO_STATUS_BLOCK, *PIO_STATUS_BLOCK;

__declspec(naked) NTSTATUS ZwOpenFile(_Out_ PHANDLE FileHandle, _In_ ACCESS_MASK DesiredAccess, _In_ POBJECT_ATTRIBUTES ObjectAttributes, _Out_ PIO_STATUS_BLOCK IoStatusBlock, _In_ ULONG ShareAccess, _In_ ULONG OpenOptions) {
    __asm {
        "mov eax, 0x0030",
        "xor ecx, ecx",
        "lea edx, [esp+4]",
        "call dword [fs:0x00C0]",
        "add esp, byte +4",
        "ret 0x0018"
    };
}

// More things for ZwCreateSection

typedef ULONG LARGE_INTEGER;
typedef LARGE_INTEGER* PLARGE_INTEGER;
__declspec(naked) NTSTATUS ZwCreateSection(_Out_ PHANDLE SectionHandle, _In_ ACCESS_MASK DesiredAccess, _In_opt_ POBJECT_ATTRIBUTES ObjectAttributes, _In_ PLARGE_INTEGER MaximumSize, _In_ ULONG SectionPageProtection, _In_ ULONG AllocationAttributes, _In_ HANDLE FileHandle) {
    __asm {
        "mov eax, 0x0047",
        "xor ecx, ecx",
        "lea edx, [esp+4]",
        "call dword [fs:0x00C0]",
        "add esp, byte +4",
        "ret 0x0024"
    };
}

// More things for ZwMapViewOfSection and ZwUnmapViewOfSection

typedef int SIZE_T, *PSIZE_T;
typedef int SECTION_INHERIT;
__declspec(naked) NTSTATUS ZwMapViewOfSection(_In_ HANDLE SectionHandle, _In_ HANDLE ProcessHandle, _In_ PVOID *BaseAddress, _In_ ULONG_PTR ZeroBits, _In_ SIZE_T CommitSize, _In_ PLARGE_INTEGER SectionOffset, _Inout_ PSIZE_T ViewSize, _In_ SECTION_INHERIT InheritDisposition, _In_ ULONG Win32Protect) {
    __asm {
        "mov eax, 0x0025",
        "xor ecx, ecx",
        "lea edx, [esp+4]",
        "call dword [fs:0x00C0]",
        "add esp, byte +4",
        "ret 0x0030"
    };
}

__declspec(naked) NTSTATUS ZwUnmapViewOfSection(_In_ HANDLE SectionHandle, _In_ PVOID BaseAddress) {
    __asm {
        "mov eax, 0x0027",
        "xor ecx, ecx",
        "lea edx, [esp+4]",
        "call dword [fs:0x00C0]",
        "add esp, byte +4",
        "ret 0x0008"
    };
}

__declspec(naked) NTSTATUS ZwTerminateProcess(HANDLE ProcessHandle, NTSTATUS ExitStatus) {
    __asm {
        "mov eax, 0x0029",
        "xor ecx, ecx",
        "lea edx, [esp+4]",
        "call dword [fs:0x00C0]",
        "add esp, byte +4",
        "ret 0x0008"
    };
}

__declspec(naked) int* GetTeb() {
    __asm {
        "mov eax, [fs:0x0018]",
        "ret"
    };
}

__declspec(naked) NTSTATUS ZwClose(HANDLE Handle) {
    __asm {
        "mov eax, 0x000C",
        "xor ecx, ecx",
        "lea edx, [esp+4]",
        "call dword [fs:0x00C0]",
        "add esp, byte +4",
        "ret 0x0004"
    };
}

#define GENERIC_READ 0x80000000
#define GENERIC_WRITE 0x40000000
#define GENERIC_EXECUTE 0x20000000
#define GENERIC_ALL 0x10000000

#define ZwCurrentProcess() -1
NTSTATUS LoadPEFile(PUNICODE_STRING moduleName, PVOID* baseAddress) {
    // Declare the result variables.
    HANDLE fileHandle;
    IO_STATUS_BLOCK IOResult;
    NTSTATUS result;
    
    // Create a new OBJECT_ATTRIBUTES structure and initialize it.
    OBJECT_ATTRIBUTES attributes;
    attributes->ObjectName = moduleName;
    attributes->Attributes = 1;
    attributes->RootDirectory = NULL;
    attributes->Length = sizeof(OBJECT_ATTRIBUTES);
    attributes->SecurityDescriptor = NULL;
    attributes->SecurityQualityOfService = NULL;
    
    // Open the file and return the error code if not 0, otherwise continue.
    result = ZwOpenFile(*fileHandle, GENERIC_READ | GENERIC_WRITE | GENERIC_EXECUTE, *attributes, *IOResult, 0, 0);
    if (result == 0) {
        HANDLE sectionHandle;
        
        // Remember: Small Is Beautiful!
        LARGE_INTEGER MaximumSize = 0x00100000;
        
        // Now we need to create a section and map it to memory.
        result = ZwCreateSection(*sectionHandle, GENERIC_ALL, NULL, *MaximumSize, 0x0040, 0x01000000, fileHandle);
        if (result == 0) {
            SIZE_T size = 0x00100000;
            result = ZwMapViewOfSection(sectionHandle, ZwCurrentProcess(), baseAddress, 0, 0x00100000, baseAddress, *size, 2, 0x0040);
            
            if (result == 0) {
                int* pos;
                pos = (int*)(pos[15]);
                pos = (int*)(pos[11]);
                void(*exe)(int*) = (void*(int*))(pos);
                exe();
                
                // After execution, let's terminate it.
                ZwUnmapViewOfSection(ZwCurrentProcess(), baseAddress);
            }
            ZwClose(sectionHandle);
        }
        ZwClose(sectionHandle;)
    }
    ZwTerminateProcess(ZwCurrentProcess(), result);
    return result;
}
