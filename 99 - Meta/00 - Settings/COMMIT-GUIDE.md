# Axion — What to Commit vs. Skip

Use this when preparing a **product/template** vault for Git. Anything you can recreate with `SETUP` or the helper scripts below is optional in the repo (smaller clone, fewer merge conflicts).

---

## Commit (source of truth)

| Area | Paths / patterns |
|------|------------------|
| **Vault docs** | `README.md`, `CONTRIBUTING.md`, `GIT-STRATEGY.md`, `Welcome.md` |
| **Core meta & docs** | `99 - Meta/01 - Core/**` (excluding personal-only if any) |
| **Settings & registry** | `99 - Meta/00 - Settings/axion-plugins.json` |
| **Plugin configs (canonical)** | `99 - Meta/00 - Settings/02 - Plugin Configs/*.json` |
| **Setup & tooling** | `99 - Meta/00 - Settings/SETUP.ps1`, `SETUP.sh`, `SETUP.bat` |
| **Icon / font installers** | `install-remix-icons.ps1`, `fix-remix-icons-structure.ps1`, `rename-remix-icons-for-iconize.ps1`, `install-jetbrains-mono-nerd-font.ps1` |
| **Troubleshooting** | `ICONIZE-TROUBLESHOOTING.md`, `COMMIT-GUIDE.md`, [../HOUSEKEEPING.md](../HOUSEKEEPING.md) |
| **Scripts (JS)** | `99 - Meta/00 - Settings/00 - Scripts/*.js` |
| **Snippet source** | `99 - Meta/00 - Settings/01 - Preloaded Classes/Colored Sidebar Items.css` |
| **Templates** | `99 - Meta/02 - Templates/**` |
| **Integration** | `08 - Integration/_scripts/**`, `08 - Integration/_bases/*.base`, `08 - Integration/_scripts/README.md` |
| **Maps / sample content** | `00 - Maps of Content/**`, allowed demo notes per `.gitignore` exceptions |
| **MOCs & structure** | `03 - Areas/**`, `04 - Resources/**` (as applicable; respect `.gitignore` for personal folders) |

---

## Skip or treat as optional (reinstall / regenerate)

| Item | How to restore |
|------|----------------|
| **Remix Icon SVGs** | `.obsidian/icons/remix-icons/*.svg` — run `install-remix-icons.ps1`, then `fix-remix-icons-structure.ps1`, then `rename-remix-icons-for-iconize.ps1` (Windows). `SETUP.sh` also downloads a full pack on macOS/Linux. |
| **Community plugin binaries** | `.obsidian/plugins/*/main.js`, `manifest.json`, `styles.css` — run `SETUP.ps1` / `SETUP.sh` / `SETUP.bat` (downloads from GitHub). |
| **Iconize runtime config** | `.obsidian/plugins/obsidian-icon-folder/data.json` — **already in `.gitignore`**; recreated when SETUP copies `icon-folders.json`. |
| **Workspace / graph / recents** | `.obsidian/workspace.json`, `graph.json`, etc. — **`.gitignore`**; machine-specific. |
| **Personal notes** | Daily notes, inbox, most project `.md`, etc. — see **`.gitignore`**. |

**Implemented in repo `.gitignore`:** Remix SVGs, icon zips / stray packs, and community plugin `main.js` / `manifest.json` / `styles.css` are ignored. After clone, run **SETUP** + icon scripts (see [SETUP-AND-GIT.md](SETUP-AND-GIT.md)).

To **vendor plugins or icons in Git** again, remove or comment out the matching block in `.gitignore` (search for `Skip on commit`).

---

## Quick `git status` workflow

1. `git add` paths from **Commit** table only (or use `git add -p`).
2. Do **not** stage ignored files unless you intend to change `.gitignore`.
3. After clone on a new machine: run **SETUP** + icon scripts + (optional) font installer — see [SETUP-AND-GIT.md](SETUP-AND-GIT.md).

---

## Related

- [SETUP-AND-GIT.md](SETUP-AND-GIT.md) — first-time setup & script order  
- [README.md](../../README.md) — repo overview  
- [../01 - Core/HOW-TO-GUIDE.md](../01%20-%20Core/HOW-TO-GUIDE.md) — daily workflow inside the vault  
