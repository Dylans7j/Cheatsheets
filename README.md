<div align="center">

# `D4RKGUNN3R // CHEATSHEETS`

![Scope](https://img.shields.io/badge/Scope-Pentest%20%7C%20AD%20%7C%20Privesc-red?style=flat-square)
![Source](https://img.shields.io/badge/Source-HTB%20Academy%20%2B%20Field%20Notes-orange?style=flat-square)
![Format](https://img.shields.io/badge/Format-Markdown-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Living%20Document-brightgreen?style=flat-square)

`RECON` · `ACTIVE DIRECTORY` · `PRIVILEGE ESCALATION` · `PIVOTING` · `WEB` · `PASSWORD ATTACKS`

Command-level reference sheets built from HTB Academy modules and real engagement/lab work — not a copy-paste of someone else's gist.

</div>

---

## // WHY THIS EXISTS

Most public cheatsheets are either too generic to be useful mid-engagement, or too narrow to generalize past the one box they came from. These are organized by **module/domain**, cover the full command with context on what it does and which platform (Linux/Windows) it runs from, and get expanded every time a technique proves itself in real use — HTB Academy content, live boxes, or the [homelab](https://github.com/Dylans7j).

Where a technique traces back to a specific machine, it links to the [full walkthrough](https://github.com/Dylans7j/HackTheBox-Walkthroughs).

---

## // INDEX

| File | Covers | Status |
|---|---|:---:|
| [`active-directory-enumeration.md`](./active-directory-enumeration.md) | LDAP enumeration, ASREPRoasting, Kerberoasting, BloodHound, DCSync, ACL abuse, Golden tickets | ✅ |
| [`attacking-common-services.md`](./attacking-common-services.md) | SMB, SQL (MySQL/MSSQL), RDP, FTP, DNS, Email — enumeration & exploitation | ✅ |
| [`attacking-common-applications.md`](./attacking-common-applications.md) | WordPress, Joomla, Drupal, Magento, Jenkins, GitLab — CMS/app exploitation | ✅ |
| [`command-injection.md`](./command-injection.md) | Injection operators, filter/blacklist bypass (Linux + Windows), blind injection | ✅ |
| [`ffuf.md`](./ffuf.md) | Directory/vhost/parameter/value fuzzing, wordlists, filter strategies | ✅ |
| [`information-gathering-web.md`](./information-gathering-web.md) | Passive OSINT (WHOIS, DNS, certs), active recon, tech stack ID, subdomain enumeration | ✅ |
| [`linux-privesc.md`](./linux-privesc.md) | SUID/SGID, sudo, cron, kernel exploits, SSH keys, library hijacking, LinPEAS | ✅ |
| [`linux-forensics-artifacts.md`](./linux-forensics-artifacts.md) | User activity logs, file timestamps, process execution, persistence mechanisms, deleted files | ✅ |
| [`password-attacks.md`](./password-attacks.md) | Brute force (hydra, netexec), hash cracking, credential hunting, Pass-The-Hash | ✅ |
| [`pivoting-tunneling.md`](./pivoting-tunneling.md) | SSH tunnels, ProxyChains, Socat, Chisel, sshuttle, Metasploit portfwd, discovery | ✅ |
| [`server-side-attacks.md`](./server-side-attacks.md) | SSRF, deserialization (Java, Python, PHP, .NET), template injection (Jinja2, Freemarker, Twig) | ✅ |
| [`sqlmap.md`](./sqlmap.md) | SQL injection enumeration, tamper scripts, file read/write, OS shell | ✅ |
| [`stack-buffer-overflow.md`](./stack-buffer-overflow.md) | Overflow detection, EIP calculation, shellcode placement, ROP chains, debugging with GDB | ✅ |
| [`web-attacks.md`](./web-attacks.md) | HTTP verb tampering, IDOR, XXE, LFI/RFI, SSRF, CORS bypass | ✅ |
| [`windows-evasion.md`](./windows-evasion.md) | AMSI bypass, PowerShell obfuscation, process injection, LOLBins, sandbox evasion | ✅ |
| [`windows-privesc.md`](./windows-privesc.md) | Unquoted paths, service ACLs, AlwaysInstallElevated, token impersonation, WinPEAS | ✅ |
| [`wifi-cracking.md`](./wifi-cracking.md) | WiFi discovery, WPA/WPA2 handshake capture, offline cracking (hashcat, aircrack), WPS, rogue AP | ✅ |
| `xss.md` | Reflected/stored/DOM XSS, cookie exfiltration, payload encoding | 🔜 |

### Forensics & Incident Response

| File | Covers | Status |
|---|---|:---:|
| [`linux-forensics-artifacts.md`](./linux-forensics-artifacts.md) | Full FHS artifact map — user activity, file timestamps, processes, persistence, deleted files | ✅ |
| `windows-forensics-artifacts.md` | Windows event logs, registry keys, file analysis, deleted files, persistence indicators | 🔜 |
| `network-forensics.md` | PCAP analysis, network indicators, anomaly detection, malware traffic patterns | 🔜 |

---

## // HIGHLIGHTS

### Active Directory — the full kill chain

From an empty network position to Domain Admin:

```
LLMNR/NTB-NS poisoning → password spraying → credentialed enumeration
  → Kerberoasting / ASREPRoasting → BloodHound path analysis
  → ACL abuse → DCSync → Golden tickets → trust exploitation
```

**File:** [`active-directory-enumeration.md`](./active-directory-enumeration.md)

### Privilege Escalation — Linux & Windows side by side

Both Linux and Windows files follow the same structure: enumerate → identify misconfiguration → exploit → verify. Real cross-references to boxes where each technique worked in practice.

**Files:** [`linux-privesc.md`](./linux-privesc.md) | [`windows-privesc.md`](./windows-privesc.md)

### Web Exploitation — reconnaissance to RCE

Passive OSINT + active recon → fuzzing → injection (SQL/command/template) → server-side exploitation (SSRF, deserialization) → CMS-specific payloads.

**Files:** [`information-gathering-web.md`](./information-gathering-web.md) · [`ffuf.md`](./ffuf.md) · [`command-injection.md`](./command-injection.md) · [`sqlmap.md`](./sqlmap.md) · [`server-side-attacks.md`](./server-side-attacks.md) · [`attacking-common-applications.md`](./attacking-common-applications.md)

### Pivoting — every tunnel, one file

SSH local/remote/dynamic forwarding, ProxyChains, Metasploit `portfwd`/`autoroute`, Chisel, sshuttle, and native Windows `netsh portproxy` — all in [`pivoting-tunneling.md`](./pivoting-tunneling.md).

### Evasion & Hardening Bypass

AV/EDR evasion (AMSI bypass, obfuscation, process injection, LOLBins), WiFi cracking (WPA/WPA2), buffer overflow exploitation with ROP chains, and stack-based BOF methodology.

**Files:** [`windows-evasion.md`](./windows-evasion.md) · [`wifi-cracking.md`](./wifi-cracking.md) · [`stack-buffer-overflow.md`](./stack-buffer-overflow.md)

### Forensics — where evidence lives

Complete Linux artifact map: user activity, filesystem metadata, process execution, persistence mechanisms, deleted files, and suspicious indicators. Covers auth logs, bash history, cron jobs, service files, and unallocated space recovery.

**File:** [`linux-forensics-artifacts.md`](./linux-forensics-artifacts.md)

---

## // CONVENTIONS

- Every command notes which **platform** it runs from (Linux attacker box vs. Windows target/attacker).
- Placeholder values use `<ANGLE_BRACKETS>` — nothing here has a real target IP baked in.
- Commands are grouped by **attack phase within each module**, matching how an actual engagement unfolds.
- Tips (💡) highlight gotchas or optimization tricks learned through practice.

---

## // CONTRIBUTING (to yourself)

New entries get added when a technique is used for real — HTB Academy modules, live boxes, or lab work — not copied from a tutorial skim without having run it.

```bash
# Git workflow
git add <modified-file>
git commit -m "Add <technique> to <file> — learned from <source>"
git push
```

<div align="center">

`BUILD // ATTACK // DETECT // DOCUMENT`

</div>
