# Migration map — flat root → folders

Your current CHEATSHEETS repo has everything in the root.  
Move files **exactly** like this (paths relative to repo root).

## Commands (copy-paste)

Run from the **root of your existing CHEATSHEETS clone** after you drop in the new folders + this file:

```bash
# create tree (safe if already exists)
mkdir -p \
  pentesting/active-directory \
  pentesting/web \
  pentesting/network-services \
  pentesting/privilege-escalation \
  pentesting/password-attacks \
  pentesting/wireless \
  pentesting/binary \
  pentesting/evasion \
  dfir osint assets scripts

# --- Active Directory ---
git mv -f active-directory-enumeration.md pentesting/active-directory/ 2>/dev/null || \
  mv -f active-directory-enumeration.md pentesting/active-directory/

# --- Web ---
for f in web-attacks.md xss.md sqlmap.md ffuf.md command-injection.md server-side-attacks.md; do
  git mv -f "$f" pentesting/web/ 2>/dev/null || mv -f "$f" pentesting/web/
done

# --- Network / services ---
for f in attacking-common-services.md attacking-common-applications.md pivoting-tunneling.md; do
  git mv -f "$f" pentesting/network-services/ 2>/dev/null || mv -f "$f" pentesting/network-services/
done

# --- Privesc ---
git mv -f linux-privesc.md pentesting/privilege-escalation/ 2>/dev/null || mv -f linux-privesc.md pentesting/privilege-escalation/
git mv -f windows-privesc.md pentesting/privilege-escalation/ 2>/dev/null || mv -f windows-privesc.md pentesting/privilege-escalation/

# --- Password ---
git mv -f password-attacks.md pentesting/password-attacks/ 2>/dev/null || mv -f password-attacks.md pentesting/password-attacks/

# --- Wireless ---
git mv -f wifi-cracking.md pentesting/wireless/ 2>/dev/null || mv -f wifi-cracking.md pentesting/wireless/

# --- Binary / evasion ---
git mv -f stack-buffer-overflow.md pentesting/binary/ 2>/dev/null || mv -f stack-buffer-overflow.md pentesting/binary/
git mv -f windows-evasion.md pentesting/evasion/ 2>/dev/null || mv -f windows-evasion.md pentesting/evasion/

# --- DFIR ---
git mv -f linux-forensics-artifacts.md dfir/ 2>/dev/null || mv -f linux-forensics-artifacts.md dfir/

# keep root README — replace with new README.md from this package
# then add new field guides:
#   pentesting/wireless/wifi-pentesting.md
#   dfir/digital-forensics.md
#   dfir/steganography.md

git status
git add -A
git commit -m "restructure: folder layout + field guides (wifi/dfir/stego)"
git push
```

## File map

| Old (repo root) | New path |
|---|---|
| `active-directory-enumeration.md` | `pentesting/active-directory/active-directory-enumeration.md` |
| `web-attacks.md` | `pentesting/web/web-attacks.md` |
| `xss.md` | `pentesting/web/xss.md` |
| `sqlmap.md` | `pentesting/web/sqlmap.md` |
| `ffuf.md` | `pentesting/web/ffuf.md` |
| `command-injection.md` | `pentesting/web/command-injection.md` |
| `server-side-attacks.md` | `pentesting/web/server-side-attacks.md` |
| `attacking-common-services.md` | `pentesting/network-services/attacking-common-services.md` |
| `attacking-common-applications.md` | `pentesting/network-services/attacking-common-applications.md` |
| `pivoting-tunneling.md` | `pentesting/network-services/pivoting-tunneling.md` |
| `linux-privesc.md` | `pentesting/privilege-escalation/linux-privesc.md` |
| `windows-privesc.md` | `pentesting/privilege-escalation/windows-privesc.md` |
| `password-attacks.md` | `pentesting/password-attacks/password-attacks.md` |
| `wifi-cracking.md` | `pentesting/wireless/wifi-cracking.md` |
| `stack-buffer-overflow.md` | `pentesting/binary/stack-buffer-overflow.md` |
| `windows-evasion.md` | `pentesting/evasion/windows-evasion.md` |
| `linux-forensics-artifacts.md` | `dfir/linux-forensics-artifacts.md` |
| `README.md` | keep at root — **replace** with new index README |

## New files to add (from this package)

| Add | Path |
|---|---|
| Full Wi-Fi guide | `pentesting/wireless/wifi-pentesting.md` |
| Forensics field guide | `dfir/digital-forensics.md` |
| Stego field guide | `dfir/steganography.md` |
| Optional PDF bundle | `assets/dfir-offensive-field-guides.pdf` |
| This migration doc | `MIGRATION.md` |
| License / gitignore | `LICENSE`, `.gitignore` |

## After migrate

1. Open GitHub → confirm folder tree looks nested (not flat).
2. Update profile project link if repo name is `CHEATSHEETS` (you already link it).
3. Optional: in HTB writeups, link  
   `../../CHEATSHEETS/pentesting/web/sqlmap.md` style paths only if monorepo — otherwise full GitHub URLs.
