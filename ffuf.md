# Ffuf (Web Fuzzing)

## Core Fuzzing Modes

| Command | Description |
|---|---|
| `ffuf -h` | Help |
| `ffuf -w wordlist.txt:FUZZ -u http://<TARGET>/FUZZ` | Directory fuzzing |
| `ffuf -w wordlist.txt:FUZZ -u http://<TARGET>/indexFUZZ` | Extension fuzzing |
| `ffuf -w wordlist.txt:FUZZ -u http://<TARGET>/blog/FUZZ.php` | Page fuzzing |
| `ffuf -w wordlist.txt:FUZZ -u http://<TARGET>/FUZZ -recursion -recursion-depth 1 -e .php -v` | Recursive fuzzing into discovered directories |
| `ffuf -w wordlist.txt:FUZZ -u https://FUZZ.target.com/` | Subdomain fuzzing |
| `ffuf -w wordlist.txt:FUZZ -u http://target.htb/ -H 'Host: FUZZ.target.htb' -fs <SIZE>` | Virtual host fuzzing — filter by response size once a baseline is known |
| `ffuf -w wordlist.txt:FUZZ -u http://<TARGET>/admin.php?FUZZ=key -fs <SIZE>` | GET parameter fuzzing |
| `ffuf -w wordlist.txt:FUZZ -u http://<TARGET>/admin.php -X POST -d 'FUZZ=key' -H 'Content-Type: application/x-www-form-urlencoded' -fs <SIZE>` | POST parameter fuzzing |
| `ffuf -w ids.txt:FUZZ -u http://<TARGET>/admin.php -X POST -d 'id=FUZZ' -H 'Content-Type: application/x-www-form-urlencoded' -fs <SIZE>` | Value fuzzing (once a valid parameter name is known) |

> 💡 `-fs <SIZE>` (filter size) is what makes vhost/parameter fuzzing usable — without it, every request "succeeds" with a 200 and the real hits get buried in noise. Always find the baseline response size for a default/invalid value first.

## Wordlists (SecLists paths)

| Purpose | Path |
|---|---|
| Directories/pages | `/opt/useful/seclists/Discovery/Web-Content/directory-list-2.3-small.txt` |
| Extensions | `/opt/useful/seclists/Discovery/Web-Content/web-extensions.txt` |
| Subdomains | `/opt/useful/seclists/Discovery/DNS/subdomains-top1million-5000.txt` |
| Parameters | `/opt/useful/seclists/Discovery/Web-Content/burp-parameter-names.txt` |

## Misc

```bash
# Add a vhost entry for local resolution
sudo sh -c 'echo "<TARGET_IP> target.htb" >> /etc/hosts'

# Generate a numeric sequence wordlist (for ID/value fuzzing)
for i in $(seq 1 1000); do echo $i >> ids.txt; done

# Manually replay a finding with curl to confirm outside ffuf
curl http://<TARGET>/admin.php -X POST -d 'id=key' -H 'Content-Type: application/x-www-form-urlencoded'
```

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README.md) collection.*

</div>
