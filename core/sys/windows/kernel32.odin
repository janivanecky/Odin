// +build windows
package sys_windows

foreign import kernel32 "system:Kernel32.lib"

@(default_calling_convention="stdcall")
foreign kernel32 {
	OutputDebugStringA :: proc(lpOutputString: LPCSTR) --- // The only A thing that is allowed
	OutputDebugStringW :: proc(lpOutputString: LPCWSTR) ---

	ReadConsoleW :: proc(hConsoleInput: HANDLE,
	                     lpBuffer: LPVOID,
	                     nNumberOfCharsToRead: DWORD,
	                     lpNumberOfCharsRead: LPDWORD,
	                     pInputControl: PCONSOLE_READCONSOLE_CONTROL) -> BOOL ---

	WriteConsoleW :: proc(hConsoleOutput: HANDLE,
	                      lpBuffer: LPCVOID,
	                      nNumberOfCharsToWrite: DWORD,
	                      lpNumberOfCharsWritten: LPDWORD,
	                      lpReserved: LPVOID) -> BOOL ---

	GetConsoleMode :: proc(hConsoleHandle: HANDLE,
	                       lpMode: LPDWORD) -> BOOL ---
	SetConsoleMode :: proc(hConsoleHandle: HANDLE,
	                       dwMode: DWORD) -> BOOL ---
	SetConsoleCursorPosition :: proc(hConsoleHandle: HANDLE,
						   dwCursorPosition: COORD) -> BOOL ---

	GetFileInformationByHandle :: proc(hFile: HANDLE, lpFileInformation: LPBY_HANDLE_FILE_INFORMATION) -> BOOL ---
	SetHandleInformation :: proc(hObject: HANDLE,
	                             dwMask: DWORD,
	                             dwFlags: DWORD) -> BOOL ---
	SetFileInformationByHandle :: proc(hFile:                HANDLE,
	                                   FileInformationClass: FILE_INFO_BY_HANDLE_CLASS,
	                                   lpFileInformation:    LPVOID,
	                                   dwBufferSize:         DWORD) -> BOOL ---


	AddVectoredExceptionHandler :: proc(FirstHandler: ULONG, VectoredHandler: PVECTORED_EXCEPTION_HANDLER) -> LPVOID ---
	AddVectoredContinueHandler  :: proc(FirstHandler: ULONG, VectoredHandler: PVECTORED_EXCEPTION_HANDLER) -> LPVOID ---
	RemoveVectoredExceptionHandler  :: proc(Handle: LPVOID) -> DWORD ---
	RemoveVectoredContinueHandler  :: proc(Handle: LPVOID) -> DWORD ---
	RaiseException :: proc(dwExceptionCode, dwExceptionFlags, nNumberOfArguments: DWORD, lpArguments: ^ULONG_PTR) -> ! ---


	CreateHardLinkW :: proc(lpSymlinkFileName: LPCWSTR,
	                        lpTargetFileName: LPCWSTR,
	                        lpSecurityAttributes: LPSECURITY_ATTRIBUTES) -> BOOL ---

	GetFileInformationByHandleEx :: proc(hFile: HANDLE,
	                                     fileInfoClass: FILE_INFO_BY_HANDLE_CLASS,
	                                     lpFileInformation: LPVOID,
	                                     dwBufferSize: DWORD) -> BOOL ---

	InitializeCriticalSection :: proc(CriticalSection: ^CRITICAL_SECTION) ---
	InitializeCriticalSectionAndSpinCount :: proc(CriticalSection: ^CRITICAL_SECTION, dwSpinCount: DWORD) -> BOOL ---
	EnterCriticalSection :: proc(CriticalSection: ^CRITICAL_SECTION) ---
	TryEnterCriticalSection :: proc(CriticalSection: ^CRITICAL_SECTION) -> BOOLEAN ---
	LeaveCriticalSection :: proc(CriticalSection: ^CRITICAL_SECTION) ---
	DeleteCriticalSection :: proc(CriticalSection: ^CRITICAL_SECTION) ---

	RemoveDirectoryW :: proc(lpPathName: LPCWSTR) -> BOOL ---
	SetFileAttributesW :: proc(lpFileName: LPCWSTR, dwFileAttributes: DWORD) -> BOOL ---
	SetLastError :: proc(dwErrCode: DWORD) ---
	GetCommandLineW :: proc() -> LPCWSTR ---
	GetTempPathW :: proc(nBufferLength: DWORD, lpBuffer: LPCWSTR) -> DWORD ---
	GetCurrentProcess :: proc() -> HANDLE ---
	GetCurrentProcessId :: proc() -> DWORD ---
	GetCurrentThread :: proc() -> HANDLE ---
	GetCurrentThreadId :: proc() -> DWORD ---
	GetProcessTimes :: proc(
		hProcess: HANDLE,
		lpCreationTime: LPFILETIME,
		lpExitTime: LPFILETIME,
		lpKernelTime: LPFILETIME,
		lpUserTime: LPFILETIME,
	) -> BOOL ---
	GetStdHandle :: proc(which: DWORD) -> HANDLE ---
	ExitProcess :: proc(uExitCode: c_uint) -> ! ---
	DeviceIoControl :: proc(
		hDevice: HANDLE,
		dwIoControlCode: DWORD,
		lpInBuffer: LPVOID,
		nInBufferSize: DWORD,
		lpOutBuffer: LPVOID,
		nOutBufferSize: DWORD,
		lpBytesReturned: LPDWORD,
		lpOverlapped: LPOVERLAPPED,
	) -> BOOL ---
	CreateThread :: proc(
		lpThreadAttributes: LPSECURITY_ATTRIBUTES,
		dwStackSize: SIZE_T,
		lpStartAddress: proc "stdcall" (rawptr) -> DWORD,
		lpParameter: LPVOID,
		dwCreationFlags: DWORD,
		lpThreadId: LPDWORD,
	) -> HANDLE ---
	CreateRemoteThread :: proc(
		hProcess: HANDLE,
		lpThreadAttributes: LPSECURITY_ATTRIBUTES,
		dwStackSize: SIZE_T,
		lpStartAddress: proc "stdcall" (rawptr) -> DWORD,
		lpParameter: LPVOID,
		dwCreationFlags: DWORD,
		lpThreadId: LPDWORD,
	) -> HANDLE ---
	SwitchToThread :: proc() -> BOOL ---
	ResumeThread :: proc(thread: HANDLE) -> DWORD ---
	GetThreadPriority :: proc(thread: HANDLE) -> c_int ---
	SetThreadPriority :: proc(thread: HANDLE, priority: c_int) -> BOOL ---
	GetExitCodeThread :: proc(thread: HANDLE, exit_code: ^DWORD) -> BOOL ---
	TerminateThread :: proc(thread: HANDLE, exit_code: DWORD) -> BOOL ---

	CreateSemaphoreW :: proc(attributes: LPSECURITY_ATTRIBUTES, initial_count, maximum_count: LONG, name: LPCWSTR) -> HANDLE ---
	ReleaseSemaphore :: proc(semaphore: HANDLE, release_count: LONG, previous_count: ^LONG) -> BOOL ---

	CreateWaitableTimerW :: proc(
		lpTimerAttributes: LPSECURITY_ATTRIBUTES,
		bManualReset: BOOL,
		lpTimerName: LPCWSTR,
	) -> HANDLE ---
	SetWaitableTimerEx :: proc(
		hTimer: HANDLE,
		lpDueTime: ^LARGE_INTEGER,
		lPeriod: LONG,
		pfnCompletionRoutine: PTIMERAPCROUTINE,
		lpArgToCompletionRoutine: LPVOID,
		WakeContext: PREASON_CONTEXT,
		TolerableDelay: ULONG,
	) -> BOOL ---
	WaitForSingleObject :: proc(hHandle: HANDLE, dwMilliseconds: DWORD) -> DWORD ---
	Sleep :: proc(dwMilliseconds: DWORD) ---
	GetProcessId :: proc(handle: HANDLE) -> DWORD ---
	CopyFileExW :: proc(
		lpExistingFileName: LPCWSTR,
		lpNewFileName: LPCWSTR,
		lpProgressRoutine: LPPROGRESS_ROUTINE,
		lpData: LPVOID,
		pbCancel: LPBOOL,
		dwCopyFlags: DWORD,
	) -> BOOL ---
	FormatMessageW :: proc(
		flags: DWORD,
		lpSrc: LPVOID,
		msgId: DWORD,
		langId: DWORD,
		buf: LPWSTR,
		nsize: DWORD,
		args: rawptr,
	) -> DWORD ---
	TlsAlloc :: proc() -> DWORD ---
	TlsFree :: proc(dwTlsIndex: DWORD) -> BOOL ---
	TlsGetValue :: proc(dwTlsIndex: DWORD) -> LPVOID ---
	TlsSetValue :: proc(dwTlsIndex: DWORD, lpTlsvalue: LPVOID) -> BOOL ---
	GetLastError :: proc() -> DWORD ---
	QueryPerformanceFrequency :: proc(lpFrequency: ^LARGE_INTEGER) -> BOOL ---
	QueryPerformanceCounter :: proc(lpPerformanceCount: ^LARGE_INTEGER) -> BOOL ---
	GetExitCodeProcess :: proc(hProcess: HANDLE, lpExitCode: LPDWORD) -> BOOL ---
	TerminateProcess :: proc(hProcess: HANDLE, uExitCode: UINT) -> BOOL ---
	CreateProcessW :: proc(
		lpApplicationName: LPCWSTR,
		lpCommandLine: LPWSTR,
		lpProcessAttributes: LPSECURITY_ATTRIBUTES,
		lpThreadAttributes: LPSECURITY_ATTRIBUTES,
		bInheritHandles: BOOL,
		dwCreationFlags: DWORD,
		lpEnvironment: LPVOID,
		lpCurrentDirectory: LPCWSTR,
		lpStartupInfo: LPSTARTUPINFO,
		lpProcessInformation: LPPROCESS_INFORMATION,
	) -> BOOL ---
	GetEnvironmentVariableW :: proc(n: LPCWSTR, v: LPWSTR, nsize: DWORD) -> DWORD ---
	SetEnvironmentVariableW :: proc(n: LPCWSTR, v: LPCWSTR) -> BOOL ---
	GetEnvironmentStringsW :: proc() -> LPWCH ---
	FreeEnvironmentStringsW :: proc(env_ptr: LPWCH) -> BOOL ---
	GetModuleFileNameW :: proc(hModule: HMODULE, lpFilename: LPWSTR, nSize: DWORD) -> DWORD ---
	CreateDirectoryW :: proc(
		lpPathName: LPCWSTR,
		lpSecurityAttributes: LPSECURITY_ATTRIBUTES,
	) -> BOOL ---
	DeleteFileW :: proc(lpPathName: LPCWSTR) -> BOOL ---
	GetCurrentDirectoryW :: proc(nBufferLength: DWORD, lpBuffer: LPWSTR) -> DWORD ---
	SetCurrentDirectoryW :: proc(lpPathName: LPCWSTR) -> BOOL ---
	WideCharToMultiByte :: proc(
		CodePage: UINT,
		dwFlags: DWORD,
		lpWideCharStr: LPCWSTR,
		cchWideChar: c_int,
		lpMultiByteStr: LPSTR,
		cbMultiByte: c_int,
		lpDefaultChar: LPCSTR,
		lpUsedDefaultChar: LPBOOL,
	) -> c_int ---
	MultiByteToWideChar :: proc(
		CodePage: UINT,
		dwFlags: DWORD,
		lpMultiByteStr: LPSTR,
		cbMultiByte: c_int,
		lpWideCharStr: LPWSTR,
		cchWideChar: c_int,
	) -> c_int ---
	DuplicateHandle :: proc(
		hSourceProcessHandle: HANDLE,
		hSourceHandle: HANDLE,
		hTargetProcessHandle: HANDLE,
		lpTargetHandle: LPHANDLE,
		dwDesiredAccess: DWORD,
		bInheritHandle: BOOL,
		dwOptions: DWORD,
	) -> BOOL ---
	ReadFile :: proc(
		hFile: HANDLE,
		lpBuffer: LPVOID,
		nNumberOfBytesToRead: DWORD,
		lpNumberOfBytesRead: LPDWORD,
		lpOverlapped: LPOVERLAPPED,
	) -> BOOL ---
	WriteFile :: proc(
		hFile: HANDLE,
		lpBuffer: LPVOID,
		nNumberOfBytesToWrite: DWORD,
		lpNumberOfBytesWritten: LPDWORD,
		lpOverlapped: LPOVERLAPPED,
	) -> BOOL ---
	CloseHandle :: proc(hObject: HANDLE) -> BOOL ---
	MoveFileExW :: proc(lpExistingFileName: LPCWSTR, lpNewFileName: LPCWSTR, dwFlags: DWORD) -> BOOL ---
	SetFilePointerEx :: proc(
		hFile: HANDLE,
		liDistanceToMove: LARGE_INTEGER,
		lpNewFilePointer: PLARGE_INTEGER,
		dwMoveMethod: DWORD,
	) -> BOOL ---
	FlushFileBuffers :: proc(hFile: HANDLE) -> BOOL ---
	CreateFileW :: proc(
		lpFileName: LPCWSTR,
		dwDesiredAccess: DWORD,
		dwShareMode: DWORD,
		lpSecurityAttributes: LPSECURITY_ATTRIBUTES,
		dwCreationDisposition: DWORD,
		dwFlagsAndAttributes: DWORD,
		hTemplateFile: HANDLE,
	) -> HANDLE ---

	FindFirstFileW :: proc(fileName: LPCWSTR, findFileData: LPWIN32_FIND_DATAW) -> HANDLE ---
	FindNextFileW :: proc(findFile: HANDLE, findFileData: LPWIN32_FIND_DATAW) -> BOOL ---
	FindClose :: proc(findFile: HANDLE) -> BOOL ---
	GetModuleHandleW :: proc(lpModuleName: LPCWSTR) -> HMODULE ---
	GetModuleHandleA :: proc(lpModuleName: LPCSTR) -> HMODULE ---
	GetSystemTimeAsFileTime :: proc(lpSystemTimeAsFileTime: LPFILETIME) ---
	CreateEventW :: proc(
		lpEventAttributes: LPSECURITY_ATTRIBUTES,
		bManualReset: BOOL,
		bInitialState: BOOL,
		lpName: LPCWSTR,
	) -> HANDLE ---
	ResetEvent :: proc(hEvent: HANDLE) -> BOOL ---
	WaitForMultipleObjects :: proc(
		nCount: DWORD,
		lpHandles: ^HANDLE,
		bWaitAll: BOOL,
		dwMilliseconds: DWORD,
	) -> DWORD ---
	CreateNamedPipeW :: proc(
		lpName: LPCWSTR,
		dwOpenMode: DWORD,
		dwPipeMode: DWORD,
		nMaxInstances: DWORD,
		nOutBufferSize: DWORD,
		nInBufferSize: DWORD,
		nDefaultTimeOut: DWORD,
		lpSecurityAttributes: LPSECURITY_ATTRIBUTES,
	) -> HANDLE ---
	CancelIo :: proc(handle: HANDLE) -> BOOL ---
	GetOverlappedResult :: proc(
		hFile: HANDLE,
		lpOverlapped: LPOVERLAPPED,
		lpNumberOfBytesTransferred: LPDWORD,
		bWait: BOOL,
	) -> BOOL ---
	GetProcessHeap :: proc() -> HANDLE ---
	HeapAlloc :: proc(hHeap: HANDLE, dwFlags: DWORD, dwBytes: SIZE_T) -> LPVOID ---
	HeapReAlloc :: proc(hHeap: HANDLE, dwFlags: DWORD, lpMem: LPVOID, dwBytes: SIZE_T) -> LPVOID ---
	HeapFree :: proc(hHeap: HANDLE, dwFlags: DWORD, lpMem: LPVOID) -> BOOL ---

	LocalAlloc :: proc(flags: UINT, bytes: SIZE_T) -> LPVOID ---
	LocalReAlloc :: proc(mem: LPVOID, bytes: SIZE_T, flags: UINT) -> LPVOID ---
	LocalFree :: proc(mem: LPVOID) -> LPVOID ---


	ReadDirectoryChangesW :: proc(
		hDirectory: HANDLE,
		lpBuffer: LPVOID,
		nBufferLength: DWORD,
		bWatchSubtree: BOOL,
		dwNotifyFilter: DWORD,
		lpBytesReturned: LPDWORD,
		lpOverlapped: LPOVERLAPPED,
		lpCompletionRoutine: LPOVERLAPPED_COMPLETION_ROUTINE,
	) -> BOOL ---

	InitializeSRWLock          :: proc(SRWLock: ^SRWLOCK) ---
	AcquireSRWLockExclusive    :: proc(SRWLock: ^SRWLOCK) ---
	TryAcquireSRWLockExclusive :: proc(SRWLock: ^SRWLOCK) -> BOOLEAN ---
	ReleaseSRWLockExclusive    :: proc(SRWLock: ^SRWLOCK) ---
	AcquireSRWLockShared    :: proc(SRWLock: ^SRWLOCK) ---
	TryAcquireSRWLockShared :: proc(SRWLock: ^SRWLOCK) -> BOOLEAN ---
	ReleaseSRWLockShared    :: proc(SRWLock: ^SRWLOCK) ---

	InitializeConditionVariable :: proc(ConditionVariable: ^CONDITION_VARIABLE) ---
	WakeConditionVariable       :: proc(ConditionVariable: ^CONDITION_VARIABLE) ---
	WakeAllConditionVariable    :: proc(ConditionVariable: ^CONDITION_VARIABLE) ---
	SleepConditionVariableCS    :: proc(ConditionVariable: ^CONDITION_VARIABLE, CriticalSection: ^CRITICAL_SECTION, dwMilliseconds: DWORD) -> BOOL ---
	SleepConditionVariableSRW   :: proc(ConditionVariable: ^CONDITION_VARIABLE, SRWLock: ^SRWLOCK, dwMilliseconds: DWORD, Flags: LONG) -> BOOL ---


	GetFileType :: proc(file_handle: HANDLE) -> DWORD ---
	SetFilePointer :: proc(file_handle: HANDLE, distance_to_move: LONG, distance_to_move_high: ^LONG, move_method: DWORD) -> DWORD ---
	GetFileSizeEx :: proc(file_handle: HANDLE, file_size: ^LARGE_INTEGER) -> BOOL ---
	GetFileAttributesW   :: proc(lpFileName: LPCWSTR) -> DWORD ---
	GetFileAttributesExW :: proc(lpFileName: LPCWSTR, fInfoLevelId: GET_FILEEX_INFO_LEVELS, lpFileInformation: LPVOID) -> BOOL ---
	GetSystemInfo :: proc(system_info: ^SYSTEM_INFO) ---
	GetVersionExW :: proc(osvi: ^OSVERSIONINFOEXW) ---

	LoadLibraryW :: proc(c_str: LPCWSTR) -> HMODULE ---
	FreeLibrary :: proc(h: HMODULE) -> BOOL ---
	GetProcAddress :: proc(h: HMODULE, c_str: LPCSTR) -> rawptr ---


	GetFullPathNameW  :: proc(filename: LPCWSTR, buffer_length: DWORD, buffer: LPCWSTR, file_part: ^LPCWSTR) -> DWORD ---
	GetLongPathNameW  :: proc(short, long: LPCWSTR, len: DWORD) -> DWORD ---
	GetShortPathNameW :: proc(long, short: LPCWSTR, len: DWORD) -> DWORD ---

	GetFinalPathNameByHandleW :: proc(hFile: HANDLE, lpszFilePath: LPCWSTR, cchFilePath: DWORD, dwFlags: DWORD) -> DWORD ---


	SetEndOfFile :: proc(hFile: HANDLE) -> BOOL ---

	CreatePipe :: proc(hReadPipe, hWritePipe: ^HANDLE, lpPipeAttributes: LPSECURITY_ATTRIBUTES, nSize: DWORD) -> BOOL ---

	ConnectNamedPipe :: proc(hNamedPipe: HANDLE, lpOverlapped: LPOVERLAPPED,) -> BOOL ---
	DisconnectNamedPipe :: proc(hNamedPipe: HANDLE,) -> BOOL ---
	WaitNamedPipeW :: proc(lpNamedPipeName: LPCWSTR, nTimeOut: DWORD,) -> BOOL ---

	SetConsoleCtrlHandler :: proc(HandlerRoutine: PHANDLER_ROUTINE, Add: BOOL) -> BOOL ---
	GenerateConsoleCtrlEvent :: proc(dwCtrlEvent: DWORD, dwProcessGroupId: DWORD) -> BOOL ---
	FreeConsole :: proc() -> BOOL ---
	GetConsoleWindow :: proc() -> HWND ---
}


SECTION_QUERY                :: DWORD(0x0001)
SECTION_MAP_WRITE            :: DWORD(0x0002)
SECTION_MAP_READ             :: DWORD(0x0004)
SECTION_MAP_EXECUTE          :: DWORD(0x0008)
SECTION_EXTEND_SIZE          :: DWORD(0x0010)
SECTION_ALL_ACCESS           :: STANDARD_RIGHTS_REQUIRED | SECTION_QUERY | SECTION_MAP_WRITE | SECTION_MAP_READ | SECTION_MAP_EXECUTE | SECTION_EXTEND_SIZE
SECTION_MAP_EXECUTE_EXPLICIT :: DWORD(0x0020)

FILE_MAP_WRITE           :: SECTION_MAP_WRITE
FILE_MAP_READ            :: SECTION_MAP_READ
FILE_MAP_ALL_ACCESS      :: SECTION_ALL_ACCESS
FILE_MAP_EXECUTE         :: SECTION_MAP_EXECUTE_EXPLICIT
FILE_MAP_COPY            :: DWORD(0x00000001)
FILE_MAP_RESERVE         :: DWORD(0x80000000)
FILE_MAP_TARGETS_INVALID :: DWORD(0x40000000)
FILE_MAP_LARGE_PAGES     :: DWORD(0x20000000)

PAGE_NOACCESS          :: 0x01
PAGE_READONLY          :: 0x02
PAGE_READWRITE         :: 0x04
PAGE_WRITECOPY         :: 0x08
PAGE_EXECUTE           :: 0x10
PAGE_EXECUTE_READ      :: 0x20
PAGE_EXECUTE_READWRITE :: 0x40
PAGE_EXECUTE_WRITECOPY :: 0x80
PAGE_GUARD             :: 0x100
PAGE_NOCACHE           :: 0x200
PAGE_WRITECOMBINE      :: 0x400

MEMORY_BASIC_INFORMATION :: struct {
	BaseAddress: PVOID,
	AllocationBase: PVOID,
	AllocationProtect: DWORD,
	PartitionId: WORD,
	RegionSize: SIZE_T,
	State: DWORD,
	Protect: DWORD,
	Type: DWORD,
}
PMEMORY_BASIC_INFORMATION :: ^MEMORY_BASIC_INFORMATION
LPMEMORY_BASIC_INFORMATION :: ^MEMORY_BASIC_INFORMATION

MEM_COMMIT      :: 0x1000
MEM_RESERVE     :: 0x2000
MEM_DECOMMIT    :: 0x4000
MEM_RELEASE     :: 0x8000
MEM_FREE        :: 0x10000
MEM_PRIVATE     :: 0x20000
MEM_MAPPED      :: 0x40000
MEM_RESET       :: 0x80000
MEM_TOP_DOWN    :: 0x100000
MEM_LARGE_PAGES :: 0x20000000
MEM_4MB_PAGES   :: 0x80000000

@(default_calling_convention="stdcall")
foreign kernel32 {
	VirtualAlloc :: proc(
		lpAddress: LPVOID,
		dwSize: SIZE_T,
		flAllocationType: DWORD,
		flProtect: DWORD,
	) -> LPVOID ---
	VirtualProtect :: proc(
		lpAddress: LPVOID,
		dwSize: SIZE_T,
		flNewProtect: DWORD,
		lpflOldProtect: PDWORD,
	) -> BOOL ---
	VirtualFree :: proc(
		lpAddress: LPVOID,
		dwSize: SIZE_T,
		dwFreeType: DWORD,
	) -> BOOL ---
	VirtualQuery :: proc(
		lpAddress: LPCVOID,
		lpBuffer: PMEMORY_BASIC_INFORMATION,
		dwLength: SIZE_T,
	) -> SIZE_T ---
	VirtualAllocEx :: proc(
		hProcess: HANDLE,
		lpAddress: LPVOID,
		dwSize: SIZE_T,
		flAllocationType: DWORD,
		flProtect: DWORD,
	) -> LPVOID ---
	VirtualFreeEx :: proc(
		hProcess: HANDLE,
		lpAddress: LPVOID,
		dwSize: SIZE_T,
		dwFreeType: DWORD,
	) -> BOOL ---
	VirtualProtectEx :: proc(
		hProcess: HANDLE,
		lpAddress: LPVOID,
		dwSize: SIZE_T,
		flNewProtect: DWORD,
		lpflOldProtect: PDWORD,
	) -> BOOL ---
	VirtualQueryEx :: proc(
		hProcess: HANDLE,
		lpAddress: LPCVOID,
		lpBuffer: PMEMORY_BASIC_INFORMATION,
		dwLength: SIZE_T,
	) -> SIZE_T ---
	ReadProcessMemory :: proc(
		hProcess: HANDLE,
		lpBaseAddress: LPCVOID,
		lpBuffer: LPVOID,
		nSize: SIZE_T,
		lpNumberOfBytesRead: ^SIZE_T,
	) -> BOOL ---
	WriteProcessMemory :: proc(
		hProcess: HANDLE,
		lpBaseAddress: LPVOID,
		lpBuffer: LPCVOID,
		nSize: SIZE_T,
		lpNumberOfBytesWritten: ^SIZE_T,
	) -> BOOL ---
	CreateFileMappingW :: proc(
		hFile: HANDLE,
		lpFileMappingAttributes: LPSECURITY_ATTRIBUTES,
		flProtect: DWORD,
		dwMaximumSizeHigh: DWORD,
		dwMaximumSizeLow: DWORD,
		lpName: LPCWSTR,
	) -> HANDLE ---
	OpenFileMappingW :: proc(
		dwDesiredAccess: DWORD,
		bInheritHandle: BOOL,
		lpName: LPCWSTR,
	) -> HANDLE ---
	MapViewOfFile :: proc(
		hFileMappingObject: HANDLE,
		dwDesiredAccess: DWORD,
		dwFileOffsetHigh: DWORD,
		dwFileOffsetLow: DWORD,
		dwNumberOfBytesToMap: SIZE_T,
	) -> LPVOID ---
	MapViewOfFileEx :: proc(
		hFileMappingObject: HANDLE,
		dwDesiredAccess: DWORD,
		dwFileOffsetHigh: DWORD,
		dwFileOffsetLow: DWORD,
		dwNumberOfBytesToMap: SIZE_T,
		lpBaseAddress: LPVOID,
	) -> LPVOID ---
	FlushViewOfFile :: proc(
		lpBaseAddress: LPCVOID,
		dwNumberOfBytesToFlush: SIZE_T,
	) -> BOOL ---
	UnmapViewOfFile :: proc(
		lpBaseAddress: LPCVOID,
	) -> BOOL ---
	GetLargePageMinimum :: proc() -> SIZE_T ---
	GetProcessWorkingSetSizeEx :: proc(
		hProcess: HANDLE,
		lpMinimumWorkingSetSize: PSIZE_T,
		lpMaximumWorkingSetSize: PSIZE_T,
		Flags: PDWORD,
	) -> BOOL ---
	SetProcessWorkingSetSizeEx :: proc(
		hProcess: HANDLE,
		dwMinimumWorkingSetSize: SIZE_T,
		dwMaximumWorkingSetSize: SIZE_T,
		Flags: DWORD,
	) -> BOOL ---
	VirtualLock :: proc(
		lpAddress: LPVOID,
		dwSize: SIZE_T,
	) -> BOOL ---
	VirtualUnlock :: proc(
		lpAddress: LPVOID,
		dwSize: SIZE_T,
	) -> BOOL ---
	GetWriteWatch :: proc(
		dwFlags: DWORD,
		lpBaseAddress: PVOID,
		dwRegionSize: SIZE_T,
		lpAddresses: ^PVOID,
		lpdwCount: ^ULONG_PTR,
		lpdwGranularity: LPDWORD,
	) -> UINT ---
	ResetWriteWatch :: proc(
		lpBaseAddress: LPVOID,
		dwRegionSize: SIZE_T,
	) -> UINT ---
}


MEMORY_RESOURCE_NOTIFICATION_TYPE :: enum c_int {
	LowMemoryResourceNotification,
	HighMemoryResourceNotification,
}
LowMemoryResourceNotification  :: MEMORY_RESOURCE_NOTIFICATION_TYPE.LowMemoryResourceNotification
HighMemoryResourceNotification :: MEMORY_RESOURCE_NOTIFICATION_TYPE.HighMemoryResourceNotification


@(default_calling_convention="stdcall")
foreign kernel32 {
	CreateMemoryResourceNotification :: proc(
		NotificationType: MEMORY_RESOURCE_NOTIFICATION_TYPE,
	) -> HANDLE ---
	QueryMemoryResourceNotification :: proc(
		ResourceNotificationHandle: HANDLE,
		ResourceState: PBOOL,
	) -> BOOL ---
}

FILE_CACHE_MAX_HARD_ENABLE  :: DWORD(0x00000001)
FILE_CACHE_MAX_HARD_DISABLE :: DWORD(0x00000002)
FILE_CACHE_MIN_HARD_ENABLE  :: DWORD(0x00000004)
FILE_CACHE_MIN_HARD_DISABLE :: DWORD(0x00000008)

@(default_calling_convention="stdcall")
foreign kernel32 {
	GetSystemFileCacheSize :: proc(
		lpMinimumFileCacheSize: PSIZE_T,
		lpMaximumFileCacheSize: PSIZE_T,
		lpFlags: PDWORD,
	) -> BOOL ---
	SetSystemFileCacheSize :: proc(
		MinimumFileCacheSize: SIZE_T,
		MaximumFileCacheSize: SIZE_T,
		Flags: DWORD,
	) -> BOOL ---
	CreateFileMappingNumaW :: proc(
		hFile: HANDLE,
		lpFileMappingAttributes: LPSECURITY_ATTRIBUTES,
		flProtect: DWORD,
		dwMaximumSizeHigh: DWORD,
		dwMaximumSizeLow: DWORD,
		lpName: LPCWSTR,
		nndPreferred: DWORD,
	) -> HANDLE ---
}

WIN32_MEMORY_RANGE_ENTRY :: struct {
	VirtualAddress: PVOID,
	NumberOfBytes: SIZE_T,
}

PWIN32_MEMORY_RANGE_ENTRY :: ^WIN32_MEMORY_RANGE_ENTRY

@(default_calling_convention="stdcall")
foreign kernel32 {
	PrefetchVirtualMemory :: proc(
		hProcess: HANDLE,
		NumberOfEntries: ULONG_PTR,
		VirtualAddresses: PWIN32_MEMORY_RANGE_ENTRY,
		Flags: ULONG,
	) -> BOOL ---
	CreateFileMappingFromApp :: proc(
		hFile: HANDLE,
		SecurityAttributes: PSECURITY_ATTRIBUTES,
		PageProtection: ULONG,
		MaximumSize: ULONG64,
		Name: PCWSTR,
	) -> HANDLE ---
	MapViewOfFileFromApp :: proc(
		hFileMappingObject: HANDLE,
		DesiredAccess: ULONG,
		FileOffset: ULONG64,
		NumberOfBytesToMap: SIZE_T,
	) -> PVOID ---
	UnmapViewOfFileEx :: proc(
		BaseAddress: PVOID,
		UnmapFlags: ULONG,
	) -> BOOL ---
	AllocateUserPhysicalPages :: proc(
		hProcess: HANDLE,
		NumberOfPages: PULONG_PTR,
		PageArray: PULONG_PTR,
	) -> BOOL ---
	FreeUserPhysicalPages :: proc(
		hProcess: HANDLE,
		NumberOfPages: PULONG_PTR,
		PageArray: PULONG_PTR,
	) -> BOOL ---
	MapUserPhysicalPages :: proc(
		VirtualAddress: PVOID,
		NumberOfPages: ULONG_PTR,
		PageArray: PULONG_PTR,
	) -> BOOL ---
	AllocateUserPhysicalPagesNuma :: proc(
		hProcess: HANDLE,
		NumberOfPages: PULONG_PTR,
		PageArray: PULONG_PTR,
		nndPreferred: DWORD,
	) -> BOOL ---
	VirtualAllocExNuma :: proc(
		hProcess: HANDLE,
		lpAddress: LPVOID,
		dwSize: SIZE_T,
		flAllocationType: DWORD,
		flProtect: DWORD,
		nndPreferred: DWORD,
	) -> LPVOID ---
}

MEHC_PATROL_SCRUBBER_PRESENT :: ULONG(0x1)

@(default_calling_convention="stdcall")
foreign kernel32 {
	GetMemoryErrorHandlingCapabilities :: proc(
		Capabilities: PULONG,
	) -> BOOL ---
}

@(default_calling_convention="stdcall")
foreign kernel32 {
	GlobalMemoryStatusEx :: proc(
		lpBuffer: ^MEMORYSTATUSEX,
	) -> BOOL ---
}

PBAD_MEMORY_CALLBACK_ROUTINE :: #type proc "stdcall" ()

@(default_calling_convention="stdcall")
foreign kernel32 {
	RegisterBadMemoryNotification :: proc(
		Callback: PBAD_MEMORY_CALLBACK_ROUTINE,
	) -> PVOID ---
	UnregisterBadMemoryNotification :: proc(
		RegistrationHandle: PVOID,
	) -> BOOL ---
}

OFFER_PRIORITY :: enum c_int {
	VmOfferPriorityVeryLow = 1,
	VmOfferPriorityLow,
	VmOfferPriorityBelowNormal,
	VmOfferPriorityNormal,
}
VmOfferPriorityVeryLow     :: OFFER_PRIORITY.VmOfferPriorityVeryLow
VmOfferPriorityLow         :: OFFER_PRIORITY.VmOfferPriorityLow
VmOfferPriorityBelowNormal :: OFFER_PRIORITY.VmOfferPriorityBelowNormal
VmOfferPriorityNormal      :: OFFER_PRIORITY.VmOfferPriorityNormal

@(default_calling_convention="stdcall")
foreign kernel32 {
	OfferVirtualMemory :: proc(
		VirtualAddress: PVOID,
		Size: SIZE_T,
		Priority: OFFER_PRIORITY,
	) -> DWORD ---
	ReclaimVirtualMemory :: proc(
		VirtualAddress: PVOID,
		Size: SIZE_T,
	) -> DWORD ---
	DiscardVirtualMemory :: proc(
		VirtualAddress: PVOID,
		Size: SIZE_T,
	) -> DWORD ---
	VirtualAllocFromApp :: proc(
		BaseAddress: PVOID,
		Size: SIZE_T,
		AllocationType: ULONG,
		Protection: ULONG,
	) -> PVOID ---
	VirtualProtectFromApp :: proc(
		Address: PVOID,
		Size: SIZE_T,
		NewProtection: ULONG,
		OldProtection: PULONG,
	) -> BOOL ---
	OpenFileMappingFromApp :: proc(
		DesiredAccess: ULONG,
		InheritHandle: BOOL,
		Name: PCWSTR,
	) -> HANDLE ---
}

WIN32_MEMORY_INFORMATION_CLASS :: enum c_int {
	MemoryRegionInfo,
}
MemoryRegionInfo :: WIN32_MEMORY_INFORMATION_CLASS.MemoryRegionInfo

WIN32_MEMORY_REGION_INFORMATION :: struct {
	AllocationBase: PVOID,
	AllocationProtect: ULONG,
	u: WIN32_MEMORY_REGION_INFORMATION_u,
	RegionSize: SIZE_T,
	CommitSize: SIZE_T,
}
WIN32_MEMORY_REGION_INFORMATION_u :: struct #raw_union {
	u: [1]u32,
	Flags: ULONG,
	s: WIN32_MEMORY_REGION_INFORMATION_u_s,
}
WIN32_MEMORY_REGION_INFORMATION_u_s :: struct {
	Bitfield: ULONG,
}
WIN32_MEMORY_REGION_INFORMATION_u_s_Bitfield :: distinct ULONG
/*bit_field #align align_of(ULONG) {
	Private        : 1-0,
	MappedDataFile : 2-1,
	MappedImage    : 3-2,
	MappedPageFile : 4-3,
	MappedPhysical : 5-4,
	DirectMapped   : 6-5,
	Reserved       : 32-6,
}*/

@(default_calling_convention="stdcall")
foreign kernel32 {
	QueryVirtualMemoryInformation :: proc(
		Process: HANDLE,
		VirtualAddress: PVOID,
		MemoryInformationClass: WIN32_MEMORY_INFORMATION_CLASS,
		MemoryInformation: PVOID,
		MemoryInformationSize: SIZE_T,
		ReturnSize: PSIZE_T,
	) -> BOOL ---
	MapViewOfFileNuma2 :: proc(
		FileMappingHandle: HANDLE,
		ProcessHandle: HANDLE,
		Offset: ULONG64,
		BaseAddress: PVOID,
		ViewSize: SIZE_T,
		AllocationType: ULONG,
		PageProtection: ULONG,
		PreferredNode: ULONG,
	) -> PVOID ---
}


NUMA_NO_PREFERRED_NODE :: 0xffffffff

MapViewOfFile2 :: #force_inline proc "stdcall" (
	FileMappingHandle: HANDLE,
	ProcessHandle: HANDLE,
	Offset: ULONG64,
	BaseAddress: PVOID,
	ViewSize: SIZE_T,
	AllocationType: ULONG,
	PageProtection: ULONG,
) -> PVOID {
	return MapViewOfFileNuma2(
		FileMappingHandle,
		ProcessHandle,
		Offset,
		BaseAddress,
		ViewSize,
		AllocationType,
		PageProtection,
		NUMA_NO_PREFERRED_NODE,
	)
}

@(default_calling_convention="stdcall")
foreign kernel32 {
	UnmapViewOfFile2 :: proc(
		ProcessHandle: HANDLE,
		BaseAddress: PVOID,
		UnmapFlags: ULONG,
	) -> BOOL ---
}

@(default_calling_convention="stdcall")
foreign kernel32 {
	GetProductInfo :: proc(
		OSMajorVersion: DWORD,
		OSMinorVersion: DWORD,
		SpMajorVersion: DWORD,
		SpMinorVersion: DWORD,
		product_type: ^Windows_Product_Type,
	) -> BOOL ---
}

HandlerRoutine :: proc "stdcall" (dwCtrlType: DWORD) -> BOOL
PHANDLER_ROUTINE :: HandlerRoutine




DCB_Config :: struct {
	fParity: bool,
	fOutxCtsFlow: bool,
	fOutxDsrFlow: bool,
	fDtrControl: DTR_Control,
	fDsrSensitivity: bool,
	fTXContinueOnXoff: bool,
	fOutX: bool,
	fInX: bool,
	fErrorChar: bool,
	fNull: bool,
	fRtsControl: RTS_Control,
	fAbortOnError: bool,
	BaudRate: DWORD,
	ByteSize: BYTE,
	Parity: Parity,
	StopBits: Stop_Bits,
	XonChar: byte,
	XoffChar: byte,
	ErrorChar: byte,
	EvtChar: byte,
}
DTR_Control :: enum byte {
	Disable = 0,
	Enable = 1,
	Handshake = 2,
}
RTS_Control :: enum byte {
	Disable   = 0,
	Enable    = 1,
	Handshake = 2,
	Toggle    = 3,
}
Parity :: enum byte {
	None  = 0,
	Odd   = 1,
	Even  = 2,
	Mark  = 3,
	Space = 4,
}
Stop_Bits :: enum byte {
	One = 0,
	One_And_A_Half = 1,
	Two = 2,
}

// A helper procedure to set the values of a DCB structure.
init_dcb_with_config :: proc "contextless" (dcb: ^DCB, config: DCB_Config) {
	out: u32

	// NOTE(tetra, 2022-09-21): On both Clang 14 on Windows, and MSVC, the bits in the bitfield
	// appear to be defined from LSB to MSB order.
	// i.e: `fBinary` (the first bitfield in the C source) is the LSB in the `settings` u32.

	out |= u32(1) << 0 // fBinary must always be true on Windows.

	out |= u32(config.fParity) << 1
	out |= u32(config.fOutxCtsFlow) << 2
	out |= u32(config.fOutxDsrFlow) << 3

	out |= u32(config.fDtrControl) << 4

	out |= u32(config.fDsrSensitivity) << 6
	out |= u32(config.fTXContinueOnXoff) << 7
	out |= u32(config.fOutX) << 8
	out |= u32(config.fInX) << 9
	out |= u32(config.fErrorChar) << 10
	out |= u32(config.fNull) << 11

	out |= u32(config.fRtsControl) << 12

	out |= u32(config.fAbortOnError) << 14

	dcb.settings = out

	dcb.BaudRate = config.BaudRate
	dcb.ByteSize = config.ByteSize
	dcb.Parity = config.Parity
	dcb.StopBits = config.StopBits
	dcb.XonChar = config.XonChar
	dcb.XoffChar = config.XoffChar
	dcb.ErrorChar = config.ErrorChar
	dcb.EvtChar = config.EvtChar

	dcb.DCBlength = size_of(DCB)
}
get_dcb_config :: proc "contextless" (dcb: DCB) -> (config: DCB_Config) {
	config.fParity = bool((dcb.settings >> 1) & 0x01)
	config.fOutxCtsFlow = bool((dcb.settings >> 2) & 0x01)
	config.fOutxDsrFlow = bool((dcb.settings >> 3) & 0x01)

	config.fDtrControl = DTR_Control((dcb.settings >> 4) & 0x02)

	config.fDsrSensitivity = bool((dcb.settings >> 6) & 0x01)
	config.fTXContinueOnXoff = bool((dcb.settings >> 7) & 0x01)
	config.fOutX = bool((dcb.settings >> 8) & 0x01)
	config.fInX = bool((dcb.settings >> 9) & 0x01)
	config.fErrorChar = bool((dcb.settings >> 10) & 0x01)
	config.fNull = bool((dcb.settings >> 11) & 0x01)

	config.fRtsControl = RTS_Control((dcb.settings >> 12) & 0x02)

	config.fAbortOnError = bool((dcb.settings >> 14) & 0x01)

	config.BaudRate = dcb.BaudRate
	config.ByteSize = dcb.ByteSize
	config.Parity = dcb.Parity
	config.StopBits = dcb.StopBits
	config.XonChar = dcb.XonChar
	config.XoffChar = dcb.XoffChar
	config.ErrorChar = dcb.ErrorChar
	config.EvtChar = dcb.EvtChar

	return
}

// NOTE(tetra): See get_dcb_config() and init_dcb_with_config() for help with initializing this.
DCB :: struct {
	DCBlength: DWORD, // NOTE(tetra): Must be set to size_of(DCB).
	BaudRate: DWORD,
	settings: u32, // NOTE(tetra): These are bitfields in the C struct.
	wReserved: WORD,
	XOnLim: WORD,
	XOffLim: WORD,
	ByteSize: BYTE,
	Parity: Parity,
	StopBits: Stop_Bits,
	XonChar: byte,
	XoffChar: byte,
	ErrorChar: byte,
	EofChar: byte,
	EvtChar: byte,
	wReserved1: WORD,
}

@(default_calling_convention="stdcall")
foreign kernel32 {
	GetCommState :: proc(handle: HANDLE, dcb: ^DCB) -> BOOL ---
	SetCommState :: proc(handle: HANDLE, dcb: ^DCB) -> BOOL ---
}


LPFIBER_START_ROUTINE :: #type proc "stdcall" (lpFiberParameter: LPVOID)

@(default_calling_convention = "stdcall")
foreign kernel32 {
	CreateFiber :: proc(dwStackSize: SIZE_T, lpStartAddress: LPFIBER_START_ROUTINE, lpParameter: LPVOID) -> LPVOID ---
	DeleteFiber :: proc(lpFiber: LPVOID) ---
	ConvertThreadToFiber :: proc(lpParameter: LPVOID) -> LPVOID ---
	SwitchToFiber :: proc(lpFiber: LPVOID) ---
}
