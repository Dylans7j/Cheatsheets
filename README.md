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

Most public cheatsheets are either too generic to be useful mid-engagement, or too narrow to generalize past the one box they came from. These are organized by **module/domain**, cover the full command with context on what it does and which platform (Linux/Windows) it runs from, and get expanded every time a technique proves itself in real use — HTB Academy content, live boxes, or the [homelab](https://github.com/Dylans7j/SOC-Lab).

Where a technique traces back to a specific machine, it links to the [full walkthrough](https://github.com/Dylans7j/HackTheBox-Walkthroughs).

---

## // INDEX

| File | Covers | Status |
|---|---|:---:|
| [`active-directory-enumeration.md`](./active-directory-enumeration.md) | LLMNR/NTB-NS poisoning, password spraying, Kerberoasting, ASREPRoasting, DCSync, ACL abuse, NoPac, PrintNightmare, PetitPotam, trust attacks | ✅ |
| [`linux-privesc.md`](./linux-privesc.md) | SUID/SGID, cron, world-writable files, LD_PRELOAD, LXD, NFS, kernel exploit triage | ✅ |
| [`windows-privesc.md`](./windows-privesc.md) | AppLocker, service ACLs, unquoted paths, credential theft, LSASS dumping, driver abuse, AlwaysInstallElevated | ✅ |
| [`pivoting-tunneling.md`](./pivoting-tunneling.md) | SSH tunnels, SOCKS proxies, Chisel, sshuttle, dnscat2, Meterpreter portfwd, ptunnel-ng | ✅ |
| `password-attacks.md` | Hash cracking, spraying methodology, wordlist strategy | 🔜 |
| `web-attacks.md` | Injection points, common web exploitation patterns | 🔜 |
| `command-injection.md` | OS command injection payloads and bypass techniques | 🔜 |
| `xss.md` | Cross-site scripting payloads and contexts | 🔜 |
| `sqlmap.md` | SQLMap flags and usage patterns | 🔜 |
| `information-gathering-web.md` | Web recon methodology | 🔜 |
| `attacking-common-services.md` | Service-specific enumeration/exploitation (SMB, FTP, etc.) | 🔜 |
| `attacking-common-applications.md` | CMS/application-specific attack patterns | 🔜 |
| `server-side-attacks.md` | SSRF, deserialization, server-side request patterns | 🔜 |
| `stack-buffer-overflow.md` | Classic stack-based BOF methodology | 🔜 |
| `windows-evasion.md` | AV/EDR evasion techniques | 🔜 |
| `ffuf.md` | Fuzzing flags and patterns | 🔜 |
| `wifi-cracking.md` | WPA/WPA2 attack techniques | 🔜 |

*(Files marked 🔜 exist in source notes and will be added incrementally.)*

---

## // HIGHLIGHTS

### Active Directory — the full kill chain in one file

From an empty network position to Domain Admin, all in one reference:

```
LLMNR/NTB-NS poisoning → password spraying → credentialed enumeration
   → Kerberoasting / ASREPRoasting → BloodHound path analysis
   → ACL abuse → DCSync → Golden/Silver tickets → trust exploitation
```

See [`active-directory-enumeration.md`](./active-directory-enumeration.md) for the full command set, covering both Linux tooling (Impacket, CrackMapExec, BloodHound.py) and native Windows/PowerView equivalents for every phase.

### Privilege Escalation — Linux & Windows side by side

Both [`linux-privesc.md`](./linux-privesc.md) and [`windows-privesc.md`](./windows-privesc.md) follow the same structure: enumerate → identify a misconfiguration class → exploit → verify. Real cross-references to boxes where each technique actually worked:

- Docker group → root: [Kobold](https://github.com/Dylans7j/HackTheBox-Walkthroughs/blob/main/kobold.md)
- Sudo rule on a user-writable script: [Nibbles](https://github.com/Dylans7j/HackTheBox-Walkthroughs/blob/main/nibbles.md)
- `SeImpersonatePrivilege` → PrintSpoofer: [Job](https://github.com/Dylans7j/HackTheBox-Walkthroughs/blob/main/job.md)

### Pivoting — every tunnel, one file

SSH local/remote/dynamic forwarding, Proxychains, Metasploit's `autoroute`/`socks_proxy`, Chisel, sshuttle, rpivot, dnscat2 (DNS tunneling), ptunnel-ng (ICMP tunneling), and native Windows `netsh portproxy` — see [`pivoting-tunneling.md`](./pivoting-tunneling.md).

---

## // CONVENTIONS

- Every command notes which platform it runs from (Linux attacker box vs. Windows target/attacker) — pivoting between the two mid-engagement is the norm, not the exception.
- Placeholder values use `<ANGLE_BRACKETS>` — nothing here has a real target IP baked in.
- Commands are grouped by **attack phase within each module** (e.g., AD enumeration → password spraying → credentialed enum → Kerberos attacks → ACL abuse → domain dominance), matching how an actual engagement unfolds.

## // CONTRIBUTING (to myself, mostly)

New entries get added when a technique is used for real — HTB Academy modules, live boxes, or lab work — not copied from a tutorial skim without having run it. Link back to the source walkthrough whenever one exists.

<div align="center">

`BUILD // ATTACK // DETECT // DOCUMENT`

</div>
