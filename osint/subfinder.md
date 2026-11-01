# Subfinder — passive subdomain discovery

[Repository index](../README.md)

**Use:** collect candidate subdomains from external sources.
**Validation:** documentation reviewed 2026-11-01; commands have not been executed in a lab.

## Workflow

Replace DOMAIN with an authorized domain. Provider API keys stay outside Git.

```bash
DOMAIN='REPLACE_WITH_AUTHORIZED_DOMAIN'
mkdir -p evidence/subfinder
subfinder -version
subfinder -ls

# Basic discovery
subfinder -d "$DOMAIN" -silent -o evidence/subfinder/names.txt

# JSON Lines with source attribution
subfinder -d "$DOMAIN" -oJ -cs -o evidence/subfinder/sources.jsonl

# Multiple domains from a scoped input file
subfinder -dL domains.txt -silent -o evidence/subfinder/multiple.txt
```

## Options and corrections

| Option | Meaning |
|---|---|
| `-s crtsh` | Select source |
| `-es alienvault` | Exclude source |
| `-all` | Use all sources; keys may be needed |
| `-recursive` | Use recursive-capable sources |
| `-rl 5` | Limit HTTP requests per second |
| `-timeout 30` | Request timeout in seconds |
| `-max-time 5` | Enumeration limit in minutes |
| `-active -oI` | Resolve results and include IPs |

## Interpret and decide

Deduplicate names, confirm scope, then resolve candidates before separate service probing. A returned name is no proof of ownership, a live website, or a vulnerability.

`-active` performs DNS resolution; it does not confirm HTTP/HTTPS availability. Subfinder is not a port scanner. Do not copy the screenshot's `-ports` or `-cidr` examples.

## Troubleshooting

No results: check spelling, provider configuration, API quotas and selected sources. Recheck installed `subfinder -h` when flags differ.

## Sources

- [Official project](https://github.com/projectdiscovery/subfinder)
- [Usage and flags](https://docs.projectdiscovery.io/opensource/subfinder/usage)
