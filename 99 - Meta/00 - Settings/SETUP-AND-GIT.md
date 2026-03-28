# Axion — Setup & Git (How to Use)

One-page guide: **new machine**, **icons**, **fonts**, and **where docs live**.

---

## 1. First-time vault setup

1. **Clone** the repo and open the folder as an Obsidian vault.
2. **Run setup** from the vault root (installs plugins, copies configs, snippets, enables community plugins):

   | OS | Command |
   |---|---------|
   | **Windows (PowerShell)** | `.\99 - Meta\00 - Settings\SETUP.ps1` |
   | **Windows (CMD)** | `99 - Meta\00 - Settings\SETUP.bat` |
   | **macOS / Linux** | `bash "99 - Meta/00 - Settings/SETUP.sh"` |

   Requirements: **curl** + **jq** (Unix script). Windows SETUP uses PowerShell only.

3. **Restart Obsidian.**

4. **Theme:** Settings → Appearance → install **Vauxhall** (or your team theme) if not bundled.

5. **Templater:** Settings → Templater → **User script folder** →  
   `99 - Meta/00 - Settings/00 - Scripts/`

6. **QuickAdd:** Wire macros from `quickadd-config.md` (paths in that file).

7. **API keys (optional):** `ANTHROPIC_API_KEY`, `GEMINI_API_KEY` for AI scripts — see main README.

---

## 2. Folder icons (Remix + Iconize)

If sidebar icons show as text or packs are missing:

**Windows (PowerShell, vault root):**

```powershell
.\99 - Meta\00 - Settings\install-remix-icons.ps1
.\99 - Meta\00 - Settings\fix-remix-icons-structure.ps1
.\99 - Meta\00 - Settings\rename-remix-icons-for-iconize.ps1
```

Or use Obsidian → **Settings → Iconize → Browse icon packs → Remix Icons → Download.**

Canonical icon **paths and names** live in:

`99 - Meta/00 - Settings/02 - Plugin Configs/icon-folders.json`

Re-run **SETUP** to copy that file to the plugin’s `data.json`.

Details: [ICONIZE-TROUBLESHOOTING.md](ICONIZE-TROUBLESHOOTING.md)

---

## 3. Fonts (JetBrains Mono Nerd)

1. Install the font:  
   `powershell -ExecutionPolicy Bypass -File "99 - Meta\00 - Settings\install-jetbrains-mono-nerd-font.ps1"`  
   Or install **JetBrains Mono Nerd Font** manually from [Nerd Fonts](https://www.nerdfonts.com/font-downloads).

2. **Appearance** is set in `.obsidian/appearance.json` (Interface / Text / Monospace).  
   Re-run **SETUP.ps1** to re-apply snippet + font keys if you reset the file.

---

## 4. What to commit

See **[COMMIT-GUIDE.md](COMMIT-GUIDE.md)**. The repo **`.gitignore`** already skips Remix SVGs, icon zips / stray packs, and plugin `main.js` / `manifest.json` / `styles.css` — run **SETUP** + icon scripts after every clone.

If those files were committed before, run once: `git rm -r --cached .obsidian/plugins .obsidian/icons/remix-icons` (then commit) so Git stops tracking them.

---

## 5. Daily use (inside the vault)

Workflow, Home.md, efforts, tasks: **[../01 - Core/HOW-TO-GUIDE.md](../01%20-%20Core/HOW-TO-GUIDE.md)**

---

## Document map

| Doc | Purpose |
|-----|---------|
| [README.md](../../README.md) | Product overview & quick start |
| **SETUP-AND-GIT.md** (this file) | Setup scripts, icons, fonts, Git |
| [COMMIT-GUIDE.md](COMMIT-GUIDE.md) | What to stage / skip for Git |
| [HOW-TO-GUIDE.md](../01%20-%20Core/HOW-TO-GUIDE.md) | Day-to-day vault usage |
| [ICONIZE-TROUBLESHOOTING.md](ICONIZE-TROUBLESHOOTING.md) | Icon pack issues |
