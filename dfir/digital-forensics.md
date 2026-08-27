# CSI Linux + Digital Forensics Field Guide

A practical reference for CSI Linux, forensic tooling, iOS analysis, photo/metadata forensics, and cryptography — with working commands for each tool.

---

## 1. CSI Linux — Does It Work?

**Yes.** CSI Linux is an actively maintained, open-source Ubuntu-based distribution purpose-built for OSINT, digital forensics, incident response, and malware analysis. It is not abandonware — the project ships regular updates and even runs its own certification (CSIL-CI).

### What it is
- **CSI Linux Analyst** — the main desktop environment, with tools pre-installed and organized by category (OSINT, forensics, malware analysis, password recovery, etc.) plus built-in **case management** for tracking investigations.
- **CSI Linux Gateway** — a TOR-ified gateway VM for anonymous dark-web research (sandboxed with AppArmor, Shorewall).
- **CSI Linux SIEM** — a log-monitoring appliance (default creds: `defender` / `Defender1!`).
- **CSI Linux Triage Drive** — a bootable forensic triage image (DD format, written with Rufus) for capturing evidence from suspect machines.

### How to run it
| Format | Notes |
|---|---|
| VirtualBox OVA | Install VirtualBox + Extension Pack, extract the `.7z`, import |
| VMware | Import the `.zip` appliance |
| KVM/QCOW2 | For Linux hosts |
| Bootable triage drive | NOT an ISO — a forensic DD image written to USB with Rufus |

**Minimum requirements (official):** 6+ GB RAM (8+ recommended), 100+ GB free disk (140+ suggested), 2+ cores, internet access. It's a heavy VM — give it 8 GB RAM / 4 cores if you can.

**Default credentials:** `csi` / `csi`

### Verdict / gotchas
- ✅ Pre-configured, lots of curated tooling, great for OSINT workflows and structured investigations.
- ⚠️ Heavy: needs a beefy host, and the main appliance is VM-only (no bare-metal ISO for the full desktop).
- ⚠️ Check licensing: personal use is free; commercial/organization use requires a paid license — see csilinux.com.
- 💡 For pure DFIR (imaging, carving, memory), Kali, SIFT, CAINE, or Paladin are comparable alternatives.

---

## 2. Disk Imaging & Acquisition

> **Golden rules:** image first, analyze the copy. Work on a write-blocked source. Record chain of custody (who, when, hash, method).

| Tool | What it does | Key command(s) |
|---|---|---|
| `dd` | Low-level bit-for-bit copy | `dd if=/dev/sdb of=/evidence/disk.dd bs=4M status=progress` |
| `dcfldd` | `dd` with built-in hashing | `dcfldd if=/dev/sdb of=disk.dd bs=4M hash=sha256 hashlog=hashes.txt` |
| `dc3dd` | `dd` with error logging + multiple outputs | `dc3dd if=/dev/sdb of=disk.dd log=errors.log hash=sha512` |
| `ewfacquire` | Create EnCase E01 images | `ewfacquire /dev/sdb -t case1 -u -m physical` |
| `ewfexport` | Extract raw image from E01 | `ewfexport case1.E01 -t disk.dd -u` |
| `guymager` | GUI imaging with metadata/hash | `guymager` |
| `hdparm` | Verify write-blocker state | `hdparm -r /dev/sdb` → `readonly = 1 (on)` |
| `sha256sum` | Verify image integrity | `sha256sum disk.dd` |

```bash
# Forensic imaging workflow
dcfldd if=/dev/sdb of=/evidence/case1/disk.dd bs=4M hash=sha256 hashlog=/evidence/case1/hashes.txt
sha256sum /evidence/case1/disk.dd          # verify after imaging
hdparm -r /dev/sdb                          # confirm source is read-only
```

---

## 3. Filesystem Analysis & Data Recovery (The Sleuth Kit + carving)

| Tool | What it does | Key command(s) |
|---|---|---|
| `mmls` | Show partition layout of an image | `mmls /evidence/disk.dd` |
| `fsstat` | Superblock / filesystem metadata | `fsstat -o 2048 /evidence/disk.dd` |
| `fls` | List files incl. deleted (by inode) | `fls -r -p -o 2048 disk.dd` / `fls -d -o 2048 disk.dd` (deleted only) |
| `istat` | Metadata for one inode | `istat -o 2048 disk.dd 12345` |
| `icat` | Dump file content by inode | `icat -o 2048 disk.dd 12345 > recovered.bin` |
| `ils` | List deleted inodes | `ils -o 2048 disk.dd` |
| `tsk_recover` | Carve all recoverable files | `tsk_recover -o 2048 disk.dd /evidence/out/` |
| `photorec` | Deep file carving (slow, thorough) | `photorec /evidence/disk.dd` |
| `foremost` | Signature-based carving | `foremost -i disk.dd -o /evidence/carved -t jpg,png,pdf,zip` |
| `scalpel` | Configurable carving (fast) | `scalpel -c /etc/scalpel/scalpel.conf -o out disk.dd` |
| `bulk_extractor` | Carve URLs, emails, hashes, GPS coords | `bulk_extractor -o /evidence/be disk.dd` |
| `binwalk` | Firmware / embedded file extraction | `binwalk -e firmware.bin` |
| `autopsy` | GUI over The Sleuth Kit | `autopsy` |

```bash
# Mount an image read-only for analysis
mkdir /mnt/ev && mount -o loop,ro,noatime /evidence/disk.dd /mnt/ev

# Quick triage: partitions → inodes → recovered files
mmls disk.dd
fls -r -p -o 2048 disk.dd > filelist.txt
ils -o 2048 disk.dd | head -50
```

---

## 4. Memory (RAM) Forensics

| Tool | What it does | Key command(s) |
|---|---|---|
| `lime` | Linux memory acquisition module | `insmod lime.ko "path=/evidence/ram.mem format=lime"` |
| `winpmem` | Windows memory acquisition | `winpmem_mini_x64_rc2.exe ram.mem` |
| `volatility3` | Analyze RAM (processes, network, injected code, credentials) | see below |
| `strings` | Pull readable strings from binary blobs | `strings -el ram.mem \| grep -i password` |
| `yara` | Scan memory for malware signatures | `yara /rules/malware.yar ram.mem` |

```bash
# Volatility 3 (auto-detects OS profile — no profile guessing)
python3 vol.py -f ram.mem windows.pslist        # process list
python3 vol.py -f ram.mem windows.pstree        # process tree
python3 vol.py -f ram.mem windows.cmdline       # command lines
python3 vol.py -f ram.mem windows.netscan       # network connections
python3 vol.py -f ram.mem windows.malfind       # injected/evasive code
python3 vol.py -f ram.mem windows.dumpfiles --pid 1234
python3 vol.py -f ram.mem windows.registry.printkey --key "Software\Microsoft\Windows\CurrentVersion\Run"
python3 vol.py -f ram.mem linux.bash            # bash history (Linux images)
```

---

## 5. Network Forensics

| Tool | What it does | Key command(s) |
|---|---|---|
| `tcpdump` | Live capture / pcap creation | `tcpdump -i eth0 -w cap.pcap -C 100 -W 20` |
| `tshark` | CLI pcap analysis (Wireshark engine) | see below |
| `wireshark` | GUI pcap analysis | `wireshark cap.pcap` |
| `zeek` | Log-based network monitoring | `zeek -r cap.pcap` |
| `nfdump` | NetFlow analysis | `nfdump -r nfcapd.* -s ip` |
| `networkminer` | Passive OSINT + file extraction from pcaps | `NetworkMiner.exe --pcap cap.pcap` |
| `xplico` | Reconstruct emails, chats, files from pcap | `xplico` |

```bash
# tshark triage one-liners
tshark -r cap.pcap -q -z io,stat,10                     # traffic volume per 10s
tshark -r cap.pcap -q -z endpoints,tcp                  # top endpoints
tshark -r cap.pcap -Y "http.request" -T fields -e http.host -e http.uri
tshark -r cap.pcap -Y "dns" -T fields -e dns.qry.name | sort -u
tshark -r cap.pcap -Y "tcp.flags.syn==1 && tcp.flags.ack==0" -T fields -e ip.dst | sort | uniq -c | sort -rn   # port-scan evidence
tshark -r cap.pcap --export-objects http,/evidence/extracted/    # carve files from HTTP streams
```

---

## 6. Log Analysis & Timelines

| Tool | What it does | Key command(s) |
|---|---|---|
| `grep`/`awk` | Fast log triage | see below |
| `journalctl` | Query systemd journal | `journalctl --since "2026-08-01" -u sshd` |
| `log2timeline`/`plaso` | Build super-timelines | `log2timeline.py /evidence/plaso.dump /mnt/ev/` |
| `psort` | Filter/export timelines | `psort.py -o l2tcsv -w timeline.csv plaso.dump` |
| `mactime` | Bodyfile → timeline | `mactime -b bodyfile.txt -d > timeline.csv` |
| `hayabusa` | Fast Windows event log triage | `hayabusa csv-timeline -d /logs -o timeline.csv` |
| `evtx_dump` | Convert Windows .evtx to readable | `python3 evtx_dump.py Security.evtx > security.json` |

```bash
# Linux: attacker brute-force fingerprint
grep "Failed password" /var/log/auth.log | awk '{print $1,$2,$3,$9,$11}' | sort | uniq -c | sort -rn | head

# Build a filesystem timeline from an image
fls -r -p -m /evidence/disk.dd /evidence/disk.dd > bodyfile.txt
mactime -b bodyfile.txt -d > timeline.csv
```

---

## 7. iOS Forensics (Deep Dive)

### Acquisition tiers (choose based on access level)
1. **Logical (iTunes/Finder backup)** — easiest, most artifacts, but only app-sandbox data the OS allows. Works on any modern iOS.
2. **Encrypted backup** — captures Keychain (passwords, tokens) that plain backups omit. Requires the user's backup password or extraction via tools like Elcomsoft Phone Breaker (with legal authority).
3. **Filesystem (checkm8/checkra1n)** — full APFS dump on checkm8-vulnerable devices (iPhone 4s–X, some iPads). Requires device in DFU mode + forensic-grade handling.
4. **Physical chip-off / JTAG** — last resort, specialist hardware.

### Key tools

| Tool | What it does | Key command(s) |
|---|---|---|
| `libimobiledevice` | iOS device access over USB | see below |
| `idevicebackup2` | Create/restore iOS backups | `idevicebackup2 backup --full /evidence/backup` |
| `ideviceinfo` | Device details (UDID, iOS version, IMEI) | `ideviceinfo -k ProductVersion` |
| `idevicedate`, `idevicesyslog` | Device clock, live syslog | `idevicesyslog \| grep -i springboard` |
| `iphonebackupreader` | Parse/decrypt iTunes backups | `iphonebackupreader /evidence/backup` |
| `MVT` (Mobile Verification Toolkit) | Detect spyware indicators (Pegasus etc.) | `mvt-ios check-backup /evidence/backup` |
| `iLEAPP` | Parse iOS artifacts (SMS, calls, location, Safari…) into HTML reports | `python3 ileapp.py -i /evidence/backup -o /evidence/report` |
| `plutil` | Read/write plist files | `plutil -p Info.plist` |
| `sqlite3` | Query artifact databases | see below |
| `strings` | Recover remnants from unallocated space | `strings -a Manifest.db \| grep -i imessage` |

### iOS backup structure (unzip the .zip, then explore)
```
Backup/
├── Info.plist            # device info, iOS version, backup password state (in encrypted backups)
├── Manifest.db           # SQLite index: fileID ↔ path on device
├── Status.plist          # backup completion state
├── 00/ 01/ ... ff/       # actual files named by SHA1 hash, sharded into folders
```

```bash
# Decrypt & unpack an iTunes backup (.zip)
unzip -P <backup_password> backup.zip -d /evidence/backup   # -P only if encrypted

# Map hashed filenames back to device paths
sqlite3 /evidence/backup/Manifest.db "SELECT fileID, relativePath FROM Files;"

# Message database
sqlite3 /evidence/backup/<hash_dir>/3d0d7e5fb2ce288813306e4d4636395e047a3d28 " \
  SELECT datetime(date,'unixepoch','localtime'), is_from_me, text \
  FROM message ORDER BY date;"

# Call history
sqlite3 <call_history.db> "SELECT datetime(date,'unixepoch','localtime'), address, duration, flags FROM call;"

# Safari history
sqlite3 <History.db> "SELECT datetime(visit_time+978307200,'unixepoch','localtime'), url, title FROM history_visits JOIN history_items ON history_visits.history_item = history_items.id;"
```

> **Note:** iOS stores most dates as **Mac Absolute Time** (seconds since 2001-01-01, i.e., +978307200 to convert to Unix).

### High-value iOS artifacts
| Artifact | Device path | What you find |
|---|---|---|
| Messages | `Library/SMS/sms.db` | iMessage/SMS, attachments, deleted-adjacent remnants |
| Call history | `Library/CallHistoryDB/CallHistory.storedata` | calls, durations, VoIP apps |
| Contacts | `Library/AddressBook/AddressBook.sqlitedb` | contacts, linked social profiles |
| Safari | `Library/Safari/History.db` | browsing history, redirects |
| Location | `Library/Caches/locationd/consolidated.db` | cell towers, Wi-Fi, GPS — full movement history |
| Keychain | `Library/Keychains/keychain-2.db` | passwords, tokens (needs encrypted backup) |
| App usage | `Library/Knowledge/knowledgeC.db` | app opens, screen time, notifications |
| Photos | `Media/DCIM/`, `Photos.sqlite` | media + metadata + deleted remnants |
| Installed apps | `Library/MobileInstallation/LastLaunchServicesMap.plist` | app inventory |
| Wireless | `Library/Preferences/com.apple.wifi.private.plist` | joined Wi-Fi networks, BSSID history |

---

## 8. Photo & Metadata Forensics

### The workhorse: `exiftool`

| What it does | Key command(s) |
|---|---|
| Read ALL metadata | `exiftool photo.jpg` |
| Read a specific tag | `exiftool -GPSLatitude -GPSLongitude photo.jpg` |
| CSV export for reports | `exiftool -csv -r /evidence/photos/ > metadata.csv` |
| JSON export | `exiftool -json photo.jpg` |
| Extract embedded thumbnail | `exiftool -b -ThumbnailImage photo.jpg > thumb.jpg` |
| Extract all embedded images | `exiftool -a -b -W %d%f_%t.%e -ext jpg .` |
| GPS → KML for mapping | `exiftool -p kml.fmt -r photos/ > locations.kml` (custom format file) |
| Strip all metadata | `exiftool -all= photo.jpg` (copies original to `photo.jpg_original`) |
| Remove GPS only | `exiftool -gps:all= photo.jpg` |
| Camera/lens fingerprinting | `exiftool -Make -Model -LensID -SerialNumber photo.jpg` |
| Find photos taken on one date | `exiftool -DateTimeOriginal="2026:08:01" -if '$DateTimeOriginal =~ /^2026:08:0/' photos/` |

### Other metadata & photo tools

| Tool | What it does | Key command(s) |
|---|---|---|
| `file` | Identify file type | `file mystery.bin` |
| `strings` | Dump readable text (hidden notes, URLs) | `strings -n 8 photo.jpg` |
| `exiv2` | EXIF/IPTC/XMP read/write | `exiv2 pr photo.jpg` / `exiv2 rm photo.jpg` |
| `mat2` | Metadata anonymization (GUI+CLI) | `mat2 photo.jpg` |
| `geotag` tools | Plot GPS on maps | use exiftool KML export → Google Earth |

### Steganography & hidden data

| Tool | What it does | Key command(s) |
|---|---|---|
| `steghide` | Hide/extract data in images/audio (no passphrase = weak) | `steghide extract -sf photo.jpg` / `steghide embed -cf cover.jpg -ef secret.txt` |
| `zsteg` | Steganography in PNG/BMP (LSB) | `zsteg -a photo.png` |
| `stegsolve` | GUI: bit-plane / LSB analysis | `stegsolve` |
| `outguess` | Legacy JPG stego | `outguess -r photo.jpg secret.txt` |
| `binwalk` | Embedded files/archives | `binwalk photo.jpg` |
| `foremost` | Carve hidden files out | `foremost -i photo.jpg -o out/` |
| `exiftool` | Comment/XPComment stashes | `exiftool -Comment photo.jpg` |
| `strings` | Plain-text stashes | `strings -n 6 photo.jpg` |

### Camera identification & integrity
- **Error Level Analysis (ELA)** — JPEG re-compression heatmap to find tampered regions. Use `forensically` (forensically.21tools.com) or Ghiro.
- **PRNU (sensor noise) matching** — ties a photo to a specific physical camera. Open-source: **Aletheia** (`aletheia.py`), academic: Fridrich's Camera Identification tool.
- **Reverse image search** for provenance: Google Lens, TinEye, Yandex Images.

---

## 9. Cryptography for Forensics

### Hashing (integrity & identification)

| Tool | What it does | Key command(s) |
|---|---|---|
| `md5sum` / `sha1sum` / `sha256sum` / `sha512sum` / `b2sum` | Standard hashes | `sha256sum file.bin` |
| `hashid` / `hash-identifier` | Identify unknown hash type | `hashid '$2y$10$...'` |
| `hashcat` | GPU password cracking | `hashcat -m 3200 hashes.txt /usr/share/wordlists/rockyou.txt` |
| `john` | CPU password cracking | `john --format=sha256crypt hashes.txt` |
| `md5deep`/`hashdeep` | Hash entire trees, hash sets | `hashdeep -r -c sha256 /evidence > manifest.txt` |
| `ssdeep` | Fuzzy hashing (similar files/malware) | `ssdeep -r /evidence/ > fuzzy.txt` |
| `tlsh` | Locality-sensitive hashing | `tlsh -f file.bin` |

```bash
# hashcat mode cheat sheet (common)
# 0 MD5 | 100 SHA1 | 1400 SHA256 | 1700 SHA512 | 3200 bcrypt | 13100 Kerberos 5 TGS
hashcat -m 1400 -a 0 hashes.txt rockyou.txt --show

# Verify evidence integrity chain
hashdeep -r -c sha256 /evidence/ | tee evidence_manifest.txt
```

### Symmetric encryption

| Tool | What it does | Key command(s) |
|---|---|---|
| `openssl enc` | AES/other block ciphers | see below |
| `gpg -c` | Symmetric GPG (AES256 default) | `gpg -c --cipher-algo AES256 secret.txt` |
| `ccrypt` | Simple file encryption | `ccrypt enc -K passphrase file.txt` |
| `cryptsetup` | LUKS disk encryption (forensics: mount w/ key) | `cryptsetup luksOpen /evidence/enc.dd vault` |
| `veracrypt` | VeraCrypt containers | `veracrypt -t -k "" --pim 0 --protect-hidden=no enc.hc /mnt/v` |

```bash
# Encrypt / decrypt with OpenSSL (classic)
openssl enc -aes-256-cbc -salt -pbkdf2 -in plain.txt -out cipher.bin
openssl enc -d -aes-256-cbc -pbkdf2 -in cipher.bin -out plain.txt

# Encrypt an evidence folder to a container
cryptsetup luksFormat /evidence/evidence.img
cryptsetup luksOpen /evidence/evidence.img vault
mkfs.ext4 /dev/mapper/vault && mount /dev/mapper/vault /mnt/vault
```

### Asymmetric crypto & keys

| Tool | What it does | Key command(s) |
|---|---|---|
| `gpg` | Full OpenPGP keypair lifecycle | see below |
| `openssl genrsa` | Generate RSA keys | `openssl genrsa -out priv.pem 2048` |
| `openssl rsa` | Manage/inspect keys | `openssl rsa -in priv.pem -pubout -out pub.pem` |
| `ssh-keygen` | SSH keys + fingerprinting | `ssh-keygen -lf key.pub` / `-y -f priv` to derive pubkey |
| `openssl x509` | Certificate inspection | `openssl x509 -in cert.pem -text -noout` |
| `openssl s_client` | Grab a live site's cert | `echo \| openssl s_client -connect example.com:443 2>/dev/null \| openssl x509 -noout -text` |
| `keytool` | Java keystores | `keytool -list -v -keystore app.jks` |

```bash
# GPG: generate, encrypt, decrypt, sign, verify
gpg --full-generate-key
gpg --encrypt --recipient victim@example.com secret.txt
gpg --decrypt secret.txt.gpg
gpg --detach-sign --armor file.txt
gpg --verify file.txt.asc file.txt

# Derive a public key from a private key (password recovery aid)
ssh-keygen -y -f id_rsa > id_rsa.pub
```

### Encoding & crypto-adjacent (CTFs, triage)

| Tool | What it does | Key command(s) |
|---|---|---|
| `xxd` / `hexdump` | Hex dump / reverse | `xxd file.bin` / `xxd -r -p hex.txt > file.bin` |
| `base64` | Base64 encode/decode | `base64 -d cipher.txt` |
| `openssl base64` | Same, more options | `openssl base64 -d -in cipher.txt` |
| `tr` | ROT13 etc. | `echo "..." \| tr 'A-Za-z' 'N-ZA-Mn-za-m'` |
| `python3` | XOR, custom transforms | `python3 -c '...'` (one-liners) |
| **CyberChef** | Swiss-army decoder (GUI, "Magic" autodetect) | gchq.github.io/CyberChef — local browser app |

```bash
# XOR a file with a single byte key (classic)
python3 - <<'EOF'
data = open('cipher.bin','rb').read()
open('plain.bin','wb').write(bytes(b ^ 0x2A for b in data))
EOF
```

---

## 10. OSINT Tools (CSI Linux's Specialty)

| Tool | What it does | Key command(s) |
|---|---|---|
| `theHarvester` | Emails, subdomains, hosts from public sources | `theHarvester -d example.com -b all -l 500` |
| `sherlock` | Find username across ~400 platforms | `sherlock --timeout 5 username` |
| `recon-ng` | Modular OSINT framework (database-backed) | `recon-ng` → `marketplace install all` |
| `spiderfoot` | Automated OSINT correlation, GUI+CLI | `spiderfoot -s example.com -o /evidence/sf.json` |
| `photon` | Deep crawl a site for OSINT crumbs | `photon -u https://example.com -o /evidence/photon` |
| `maltego` | Link analysis / graph intelligence | `maltego` (GUI; community edition) |
| `whois` | Domain registration data | `whois example.com` |
| `dig` / `host` | DNS records | `dig example.com ANY` / `dig -x 8.8.8.8` |
| `dnsrecon` | DNS enumeration | `dnsrecon -d example.com -t std,brt` |
| `whatweb` | Website fingerprinting | `whatweb -v https://example.com` |
| `shodan` CLI | Internet-wide device search | `shodan host 8.8.8.8` / `shodan search "port:554"` |
| `waybackurls` | Historical URLs from archives | `waybackurls example.com > urls.txt` |
| `exiftool` (OSINT mode) | Pull GPS/author metadata from published photos | `exiftool -a -gps:all downloaded.jpg` |
| `gallery-dl` | Bulk download media from many sites | `gallery-dl https://twitter.com/user` |

```bash
# Find a person/org's digital footprint
theHarvester -d example.com -b google,twitter,linkedin
sherlock johndoe
whois example.com && dig example.com ANY +noall +answer
```

---

## 11. Quick-Reference Cheat Table

| Task | Tool | One-liner |
|---|---|---|
| Image a disk | `dcfldd` | `dcfldd if=/dev/sdb of=img.dd bs=4M hash=sha256` |
| List deleted files | `fls` | `fls -r -d -o 2048 img.dd` |
| Recover everything | `tsk_recover` | `tsk_recover -o 2048 img.dd out/` |
| Carve images | `foremost` | `foremost -i img.dd -o out -t jpg,png` |
| Analyze RAM | `volatility3` | `python3 vol.py -f ram.mem windows.pslist` |
| Pcap HTTP requests | `tshark` | `tshark -r cap.pcap -Y "http.request"` |
| Read EXIF | `exiftool` | `exiftool -a -gps:all photo.jpg` |
| Carve stego | `zsteg`/`steghide` | `zsteg -a img.png` / `steghide extract -sf img.jpg` |
| iOS backup parse | `iLEAPP` | `python3 ileapp.py -i backup -o report` |
| iOS spyware check | `MVT` | `mvt-ios check-backup backup/` |
| Crack hashes | `hashcat` | `hashcat -m 1400 -a 0 hashes.txt rockyou.txt` |
| AES encrypt | `openssl` | `openssl enc -aes-256-cbc -pbkdf2 -in f -out f.enc` |
| GPG sign/verify | `gpg` | `gpg --detach-sign f` → `gpg --verify f.asc f` |

---

## 12. Practice Resources & Learning Path

1. **CSI Linux CSIL-CI** certification materials (free PDFs on csilinux.com) — structured intro to the distro.
2. **CyberDefenders** (cyberdefenders.org) — free blue-team forensics labs with real artifacts (SMS, memory, pcap challenges).
3. **Hack The Box** Forensics track + retired forensics boxes.
4. **TryHackMe** — DFIR, iOS/Android, and OSINT rooms for guided practice.
5. **DFIR DIZZY / 13Cubed** YouTube — excellent practical walkthroughs (memory, iOS, timeline).
6. **Build your own corpus:** back up your own phone, dump a USB stick, image an SD card — practice the exact commands in this guide.
7. **CyberChef** — master it; it solves 50% of CTF crypto/stego triage.

---

*Author's note: Always work from copies, document chain of custody, and ensure you have legal authority before acquiring or analyzing evidence. Commands target Linux (Kali/CSI/SIFT); Windows equivalents exist for most tools.*
