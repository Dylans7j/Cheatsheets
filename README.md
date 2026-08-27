# CHEATSHEETS

**D4RKGUNN3R // command reference & field guides**

Offense · DFIR · OSINT — notes I actually use in lab, HTB, and authorized work.

> Build the lab. Attack the system. Detect the activity. Document the findings.

**Owner:** [Dylans7j](https://github.com/Dylans7j) · handle: `d4rkgunn3r`

---

## Layout

```text
CHEATSHEETS/
├── pentesting/
│   ├── active-directory/     # AD enum, Kerberos, BloodHound paths
│   ├── web/                  # XSS, SQLi, SSRF, ffuf, web methodology
│   ├── network-services/     # common services, pivoting, tunneling
│   ├── privilege-escalation/ # Linux + Windows privesc
│   ├── password-attacks/     # hashcat, spray, cracking
│   ├── wireless/             # Wi-Fi (aircrack, airgeddon, evil twin)
│   ├── binary/               # stack BOF, basic exploit dev
│   └── evasion/              # Windows evasion notes
├── dfir/                     # forensics, stego, artifacts
├── osint/                    # open-source intel (expand later)
└── assets/                   # PDFs / diagrams
```

---

## Index

### Pentesting — Active Directory

| Sheet | File |
|---|---|
| AD enumeration | [`active-directory-enumeration.md`](pentesting/active-directory/active-directory-enumeration.md) |

### Pentesting — Web

| Sheet | File |
|---|---|
| Web attacks | [`web-attacks.md`](pentesting/web/web-attacks.md) |
| XSS | [`xss.md`](pentesting/web/xss.md) |
| SQLMap | [`sqlmap.md`](pentesting/web/sqlmap.md) |
| FFUF | [`ffuf.md`](pentesting/web/ffuf.md) |
| Command injection | [`command-injection.md`](pentesting/web/command-injection.md) |
| Server-side attacks | [`server-side-attacks.md`](pentesting/web/server-side-attacks.md) |

### Pentesting — Network & services

| Sheet | File |
|---|---|
| Attacking common services | [`attacking-common-services.md`](pentesting/network-services/attacking-common-services.md) |
| Attacking common applications | [`attacking-common-applications.md`](pentesting/network-services/attacking-common-applications.md) |
| Pivoting & tunneling | [`pivoting-tunneling.md`](pentesting/network-services/pivoting-tunneling.md) |

### Pentesting — Privilege escalation

| Sheet | File |
|---|---|
| Linux privesc | [`linux-privesc.md`](pentesting/privilege-escalation/linux-privesc.md) |
| Windows privesc | [`windows-privesc.md`](pentesting/privilege-escalation/windows-privesc.md) |

### Pentesting — Password attacks

| Sheet | File |
|---|---|
| Password attacks | [`password-attacks.md`](pentesting/password-attacks/password-attacks.md) |

### Pentesting — Wireless

| Sheet | File |
|---|---|
| **Wi-Fi field guide (full)** | [`wifi-pentesting.md`](pentesting/wireless/wifi-pentesting.md) |
| Wi-Fi cracking (short) | [`wifi-cracking.md`](pentesting/wireless/wifi-cracking.md) |

### Pentesting — Binary / evasion

| Sheet | File |
|---|---|
| Stack buffer overflow | [`stack-buffer-overflow.md`](pentesting/binary/stack-buffer-overflow.md) |
| Windows evasion | [`windows-evasion.md`](pentesting/evasion/windows-evasion.md) |

### DFIR

| Sheet | File |
|---|---|
| **Digital forensics field guide** | [`digital-forensics.md`](dfir/digital-forensics.md) |
| **Steganography field guide** | [`steganography.md`](dfir/steganography.md) |
| Linux forensics artifacts | [`linux-forensics-artifacts.md`](dfir/linux-forensics-artifacts.md) |

### OSINT

| Sheet | File |
|---|---|
| *(expand here)* | [`osint/`](osint/) |

---

## Quick search

```bash
git clone https://github.com/Dylans7j/CHEATSHEETS.git
cd CHEATSHEETS
rg -n -i "bloodhound|pmkid|sqlmap|sysmon" .
```

Optional zsh aliases ([d4rkgunn3r-zsh-Setup](https://github.com/Dylans7j/d4rkgunn3r-zsh-Setup)):

```zsh
export CHEATS=~/git/CHEATSHEETS
alias cheats='cd $CHEATS && ls'
alias wifi-cheat='less $CHEATS/pentesting/wireless/wifi-pentesting.md'
alias ad-cheat='less $CHEATS/pentesting/active-directory/active-directory-enumeration.md'
alias dfir-cheat='less $CHEATS/dfir/digital-forensics.md'
```

---

## Related ops

| Project | Role |
|---|---|
| [SOC-Lab](https://github.com/Dylans7j/SOC-Lab) | Attack → telemetry → Sentinel/Splunk detection |
| [HackTheBox-Walkthroughs](https://github.com/Dylans7j/HackTheBox-Walkthroughs) | Full box narratives (link sheets; don’t dump refs there) |
| [CS499-ePortfolio](https://github.com/Dylans7j/CS499-ePortfolio) | Capstone / career showcase |
| [d4rkgunn3r-zsh-Setup](https://github.com/Dylans7j/d4rkgunn3r-zsh-Setup) | Terminal config |

---

## Rules of engagement (for this repo)

1. **One topic per file.** Walkthroughs live in HTB repo.
2. Prefer **working commands** over long theory.
3. No secrets, VPN configs, live target data, or credentials.
4. Offensive content = **authorized labs, CTFs, and written-scope work only**.

---

## Migrate from flat root (if you still have old layout)

```bash
# From repo root after pulling this structure:
bash scripts/migrate-flat-to-folders.sh
```

See [`MIGRATION.md`](MIGRATION.md) for the full map.

---

## License

MIT — see [LICENSE](LICENSE).

**Authorized use only.**
