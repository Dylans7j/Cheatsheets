# Upload to GitHub (no CLI required)

Your username is **Dylans7j**. Repo: **https://github.com/Dylans7j/CHEATSHEETS**

## Method 1 — Web UI (fastest if you don't use git locally)

### A) Replace README
1. Open https://github.com/Dylans7j/CHEATSHEETS
2. Click `README.md` → pencil → paste contents of `README.md` from this package → Commit.

### B) Add folders + new guides
GitHub web upload only works at one folder level at a time. Easier path:

1. On repo page: **Add file → Upload files**
2. Drag these **folders** from the unpacked package:
   - `pentesting/`
   - `dfir/`
   - `osint/`
   - `assets/`
   - `scripts/`
3. Also upload: `MIGRATION.md`, `LICENSE`, `.gitignore`, `UPLOAD-TO-GITHUB.md`
4. Commit message: `restructure: topic folders + wifi/dfir/stego field guides`

### C) Move your existing root .md files
After folders exist, for each old root file either:
- **Web:** open file → `...` → Move file → type new path from `MIGRATION.md`
- **Or** clone + run: `bash scripts/migrate-flat-to-folders.sh`

### D) Profile README
1. Open https://github.com/Dylans7j/Dylans7j (profile repo; create if missing — name must equal username)
2. Edit `README.md` → paste `Dylans7j-profile-README.md` from this package
3. Pin: SOC-Lab, CHEATSHEETS, HackTheBox-Walkthroughs, CS499-ePortfolio

## Method 2 — Local git (recommended)

```bash
tar -xzf CHEATSHEETS-restructure-package.tar.gz
cd your-existing-CHEATSHEETS-clone

# copy new scaffolding
cp -a /path/to/unpacked/Cheatsheets/* .
cp -a /path/to/unpacked/Cheatsheets/.gitignore .

# move your old root sheets into folders
bash scripts/migrate-flat-to-folders.sh

# new guides already in pentesting/wireless + dfir from the package
git add -A
git status
git commit -m "restructure: topic folders + wifi/dfir/stego field guides"
git push origin main
```

## What stays where

| Content | Repo |
|---|---|
| Command sheets / field guides | **CHEATSHEETS** |
| Full HTB box writeups | HackTheBox-Walkthroughs |
| AD attack→detect lab | SOC-Lab |
| Dotfiles | d4rkgunn3r-zsh-Setup |
| Career story | CS499-ePortfolio + profile README |

## wifi-cracking.md vs wifi-pentesting.md

- Keep **both**.
- `wifi-cracking.md` = your short notes
- `wifi-pentesting.md` = full field guide (airgeddon, evil twin, PMKID, etc.)
- Optionally add one line at top of `wifi-cracking.md`:  
  `> Full guide: [wifi-pentesting.md](./wifi-pentesting.md)`
