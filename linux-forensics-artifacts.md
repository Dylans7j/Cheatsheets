# Linux Forensics - Artifacts

Complete map of where evidence lives in the Linux filesystem hierarchy (FHS).

## User Activity & Sessions

### Login/Logout Activity

| File | Contains |
|---|---|
| `/var/log/auth.log` | SSH logins, sudo usage, authentication failures |
| `/var/log/secure` | RHEL/CentOS auth logs (same as auth.log) |
| `/var/log/wtmp` | Binary log of login/logout records |
| `/var/log/btmp` | Binary log of failed login attempts |
| `/var/run/utmp` | Current user sessions (binary) |

**Read binary logs:**

```bash
# Display login history
last -f /var/log/wtmp

# Display failed logins
lastb -f /var/log/btmp

# Display currently logged-in users
who /var/run/utmp
```

### Command History

| Location | Contains |
|---|---|
| `~/.bash_history` | Bash command history (default last 1000) |
| `~/.zsh_history` | Zsh command history |
| `~/.ksh_history` | Korn shell history |
| `/root/.bash_history` | Root's command history (risky to read during investigation) |
| `/var/log/audit/audit.log` | Audit daemon (if enabled) — high fidelity command tracking |

**Check for history tampering:**

```bash
# Compare file modification time with current shell history
stat ~/.bash_history
ls -la ~/.bash_history

# History file deleted or modified after logoff = tampering indicator
```

> 💡 Attackers often clear history with `history -c` or `rm ~/.bash_history`. Check modification time of `.bash_history` against system logs.

## File System Activity

### File Metadata & Timestamps

| Timestamp | Meaning |
|---|---|
| `mtime` (mod) | Last time content changed |
| `atime` (access) | Last time file was read |
| `ctime` (change) | Last time metadata changed (cannot be spoofed; saved by kernel) |
| `btime` (birth) | Creation time (ext4+ only) |

**Read extended attributes:**

```bash
# Show all timestamps
stat /path/to/file

# List mtime only
ls -la /path/to/file

# Find files modified in last 24 hours
find / -mtime -1

# Find accessed in last 7 days
find / -atime -7

# Use `debugfs` for ext4 filesystem timestamps
debugfs -R 'stat <inode>' /dev/sda1
```

### Recently Modified Files

```bash
# Last 50 modified files in /home
find /home -type f -printf '%T@ %p\n' | sort -rn | head -50

# Find all files modified during specific time window
find / -type f -newermt "2024-01-01" ! -newermt "2024-01-31"

# Find recently created files (suspicious)
find / -type f -ctime -7 | grep -E "(\.sh$|\.php$|\.py$)" 
```

### Filesystem Journals (ext4, ext3)

```bash
# Extract filesystem journal (may reveal deleted file contents)
debugfs /dev/sda1
> logdump -O

# Or use recovery tools
extundelete /dev/sda1 --restore-all

# Recover deleted files from unallocated space
foremost -i /dev/sda1 -o /tmp/recovered
```

## Process & Runtime Activity

### Process Execution Logs

| File | Contains |
|---|---|
| `/var/log/syslog` | General system logs (processes, kernel messages) |
| `/var/log/messages` | RHEL/CentOS equivalent of syslog |
| `/var/log/audit/audit.log` | Audit daemon logs (if `auditd` running) |

**Enable detailed process auditing:**

```bash
# Show all execve syscalls
auditctl -w /usr/bin/ -p x -k binary_exec

# Show file access
auditctl -w /etc/shadow -p rwa -k shadow_access

# View audit logs
ausearch -k binary_exec
```

### Cron Job History

| File | Contains |
|---|---|
| `/var/log/syslog` | Cron job execution (grep for "CRON\|CMD") |
| `/var/log/auth.log` | Sudo commands run via cron |
| `/etc/crontab` | System-wide cron jobs |
| `/etc/cron.d/` | Additional cron files |
| `/var/spool/cron/crontabs/` | User cron jobs (one file per user) |

**Check cron execution:**

```bash
# Find cron entries that ran
grep CRON /var/log/auth.log | tail -20

# View all scheduled jobs
cat /etc/crontab
ls -la /etc/cron.d/
cat /var/spool/cron/crontabs/*  # Readable by root only
```

## Network Activity

### Network Connections

| File | Contains |
|---|---|
| `/proc/net/tcp` | Active TCP connections (kernel state, not logs) |
| `/proc/net/udp` | Active UDP connections |
| `/var/log/auth.log` | SSH connections, failed login attempts |
| `/var/log/apache2/access.log` | Web server requests |
| `/var/log/apache2/error.log` | Web server errors |

**View active connections (runtime):**

```bash
# Show connections
ss -antup | grep ESTABLISHED

# Or older method
netstat -antup

# Find process associated with connection
lsof -i :22  # SSH connections
```

### DNS Queries

| File | Contains |
|---|---|
| `/var/log/apt/history.log` | Package installation (DNS resolution during install) |
| `~/.bash_history` | DNS commands (host, dig, nslookup) |
| `/var/log/syslog` | DHCP/DNS activity (if logged) |

> 💡 DNS resolution is rarely logged in Linux unless using systemd-resolved with logging enabled.

```bash
# Enable systemd-resolved logging
mkdir -p /etc/systemd/resolved.conf.d
echo -e "[Resolve]\nDNSSEC=yes\nDNSSECNegativeTrustAnchors=" > /etc/systemd/resolved.conf.d/logging.conf
```

## Package & Software Activity

### Package Management

| File | Contains |
|---|---|
| `/var/log/apt/history.log` | Debian/Ubuntu package installs, removes, upgrades |
| `/var/log/apt/term.log` | APT terminal output |
| `/var/log/yum.log` | RHEL/CentOS package manager logs |
| `/var/log/pacman.log` | Arch Linux package logs |

```bash
# View install history
cat /var/log/apt/history.log | grep "Package:"

# Find suspicious packages
grep -E "(gcc|g\+\+|make|build|miner|httpd)" /var/log/apt/history.log
```

### Software Compilation

```bash
# Look for compiler usage in command history
grep -E "(gcc|g\+\+|cc|make|python)" ~/.bash_history

# Find recently compiled binaries
find / -type f -perm /u+x,g+x,o+x -newermt "2024-01-01" -ls | head -20
```

## Persistence Mechanisms

### Startup Scripts & Services

| File | Purpose |
|---|---|
| `/etc/init.d/` | Init.d startup scripts |
| `/etc/systemd/system/` | Systemd service files (most modern) |
| `/lib/systemd/system/` | System service files |
| `/etc/rc.local` | Local startup script |
| `~/.bashrc`, `~/.bash_profile` | User shell startup (may contain persistence) |

**Suspicious indicators:**

```bash
# Check for unusual services
ls -la /etc/systemd/system/ | grep -v "^d" | grep -v "^total"

# Check init scripts
find /etc/init.d/ -newer /var/log/auth.log -type f

# Check .bashrc for reverse shells or curl commands
grep -E "(bash|sh|nc|telnet|curl|wget)" ~/.bashrc ~/.bash_profile
```

### Scheduled Tasks (Cron & At)

```bash
# View system cron
cat /etc/crontab

# View user cron jobs
crontab -l  # Current user
crontab -u <USER> -l  # Specific user (root only)

# Check for suspicious cron entries
grep -E "(nc|bash|curl|wget|nohup)" /etc/crontab /var/spool/cron/crontabs/*
```

## Deleted/Hidden Files

### Unallocated Space & Deleted Files

```bash
# Search unallocated space for strings
strings /dev/sda1 | grep -i "password\|api\|key"

# Recover deleted files
extundelete /dev/sda1 --restore-all
photorec /dev/sda1  # Works on multiple filesystems
```

### Hidden Files

```bash
# Files starting with dot (.) are hidden in Linux
ls -la ~/ | grep "^-.*\."  # Show hidden files in home

# Suspicious naming
ls -la / | grep -E "^\..{8}$"  # Hidden files with 8-char names
```

## Temporary Files

| Location | Purpose |
|---|---|
| `/tmp/` | World-writable temporary directory |
| `/var/tmp/` | Persistent temporary files (survives reboot) |
| `/dev/shm/` | In-memory temporary filesystem |

**Find suspicious files:**

```bash
# Recently created temp files
find /tmp -type f -newermt "2024-01-01" -ls

# Executable files in /tmp
find /tmp -type f -perm /u+x,g+x,o+x -ls

# Strings in /dev/shm (RAM-based, often used by malware)
strings /dev/shm/* 2>/dev/null | head -50
```

## Configuration & Sensitive Files

### Modified System Configs

```bash
# Find configs modified recently
find /etc -type f -newermt "2024-01-01" -ls

# Check for suspicious SSH config modifications
stat /etc/ssh/sshd_config
diff /etc/ssh/sshd_config.orig /etc/ssh/sshd_config

# Look for backdoored sudoers
visudo -c  # Check syntax
grep -E "NOPASSWD|ALL=\(ALL\)" /etc/sudoers*
```

### System Accounts & Permissions

```bash
# Check for new/suspicious users
cat /etc/passwd | awk -F: '{print $1, $3}'  # UID >= 1000 is suspicious if system account

# SUID/SGID binaries (privilege escalation vectors)
find / -perm /u+s,g+s -ls | grep -v "^/proc\|^/sys"
```

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README-CHEATSHEETS.md) collection.*

</div>
