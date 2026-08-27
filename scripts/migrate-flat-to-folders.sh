#!/usr/bin/env bash
# Run from CHEATSHEETS repo root.
# Moves existing flat .md files into the topic folder layout.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "[*] Repo root: $ROOT"

mkdir -p \
  pentesting/active-directory \
  pentesting/web \
  pentesting/network-services \
  pentesting/privilege-escalation \
  pentesting/password-attacks \
  pentesting/wireless \
  pentesting/binary \
  pentesting/evasion \
  dfir osint assets

move() {
  local src="$1" dest="$2"
  if [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$dest")"
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      git mv -f "$src" "$dest" 2>/dev/null || mv -f "$src" "$dest"
    else
      mv -f "$src" "$dest"
    fi
    echo "  moved  $src  ->  $dest"
  else
    echo "  skip   $src (not found)"
  fi
}

move active-directory-enumeration.md pentesting/active-directory/active-directory-enumeration.md

move web-attacks.md            pentesting/web/web-attacks.md
move xss.md                    pentesting/web/xss.md
move sqlmap.md                 pentesting/web/sqlmap.md
move ffuf.md                   pentesting/web/ffuf.md
move command-injection.md      pentesting/web/command-injection.md
move server-side-attacks.md    pentesting/web/server-side-attacks.md

move attacking-common-services.md      pentesting/network-services/attacking-common-services.md
move attacking-common-applications.md  pentesting/network-services/attacking-common-applications.md
move pivoting-tunneling.md             pentesting/network-services/pivoting-tunneling.md

move linux-privesc.md   pentesting/privilege-escalation/linux-privesc.md
move windows-privesc.md pentesting/privilege-escalation/windows-privesc.md

move password-attacks.md pentesting/password-attacks/password-attacks.md

move wifi-cracking.md pentesting/wireless/wifi-cracking.md

move stack-buffer-overflow.md pentesting/binary/stack-buffer-overflow.md
move windows-evasion.md       pentesting/evasion/windows-evasion.md

move linux-forensics-artifacts.md dfir/linux-forensics-artifacts.md

echo
echo "[+] Migration complete."
echo "    Next:"
echo "      1) Replace root README.md with the new index (if not already)."
echo "      2) Ensure new guides exist:"
echo "         pentesting/wireless/wifi-pentesting.md"
echo "         dfir/digital-forensics.md"
echo "         dfir/steganography.md"
echo "      3) git add -A && git commit -m 'restructure cheatsheets' && git push"
echo
ls -la pentesting/*/ dfir/ 2>/dev/null || true
