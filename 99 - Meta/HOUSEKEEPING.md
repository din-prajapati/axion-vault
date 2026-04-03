# Axion — Housekeeping: Files Safe to Archive

Files and folders that are not required for core operation and can be safely archived (moved to `07 - Archives` or removed).

---

## High confidence — safe to archive

| File | Reason |
|------|--------|
| `99 - Meta/02 - Templates/(TEMPLATE) Daily (Original).md` | Superseded by `(TEMPLATE) Daily.md` (Templater + Dataview). Original uses plain date frontmatter and table-based schedule; current Daily uses Templater and Dataview queries. |
| `99 - Meta/01 - Core/_scripts/live-layout-switcher.js` | Not referenced anywhere. `layout-switcher.js` is the active script used by Project/Person/Base templates and docs. Live version appears experimental. |
| `99 - Meta/00 - Settings/.obsidian/` (entire folder) | Nested `.obsidian` inside Settings. Contains `appearance.json` only. Root `.obsidian/appearance.json` is what Obsidian uses for the vault. This is redundant. |

---

## Medium confidence — consider archiving

| Item | Reason |
|------|--------|
| `99 - Meta/02 - Templates/FocusReset/` (7-day folder) | One-time "Digital Detox" / purpose-alignment template. 7 notes (Day 1–7) that may have been used once. Move to `07 - Archives/99 - Meta/FocusReset/` if you no longer run this program. |
| `99 - Meta/01 - Core/_templates/Capacities-Layout-Scaffold.md` | DataviewJS alternative scaffold. Project-Template, Person-Template, Base-Object-Template use inline `layout-switcher` + layout-switcher.js. Only archive if you never use the scaffold directly in notes. |
| `99 - Meta/CLAUDE_COWORK.md` | Session context for AI tools. Already in `.gitignore` as `CLAUDE_COWORK.md`. If committed by mistake, safe to remove from repo (keep local). |

---

## Icons — config fix (not archive)

| Issue | Action |
|------|--------|
| `RiHome4Line` in icon-folders.json | Referenced for Home.md but not in the installed Remix pack (45 icons). Change to `RiMap2Line` (or another existing icon) in `icon-folders.json` to avoid "icon as text" on Home. |

---

## Kept — do not archive

| Category | Files |
|----------|-------|
| Setup scripts | SETUP.ps1, SETUP.sh, SETUP.bat, install-remix-icons.ps1, fix-remix-icons-structure.ps1, rename-remix-icons-for-iconize.ps1 |
| QuickAdd scripts | ai-ask.js, generate-claude-md.js, move-effort.js, quick-task.js |
| Core scripts | layout-switcher.js, property-inheritance.js, schema-validator.js |
| Templates | All (TEMPLATE) *.md except Daily (Original) |
| .obsidian | plugins/, snippets/, themes/, icons/remix-icons/ — all in use |

---

## Archive command (PowerShell)

```powershell
# From vault root
$ARCHIVE = "07 - Archives/99 - Meta"
New-Item -ItemType Directory -Force -Path $ARCHIVE

# High confidence
Move-Item "99 - Meta/02 - Templates/(TEMPLATE) Daily (Original).md" $ARCHIVE -Force
Move-Item "99 - Meta/01 - Core/_scripts/live-layout-switcher.js" $ARCHIVE -Force
Remove-Item "99 - Meta/00 - Settings/.obsidian" -Recurse -Force   # or Move to $ARCHIVE

# Optional: FocusReset
# Move-Item "99 - Meta/02 - Templates/FocusReset" $ARCHIVE -Force
```

After archiving, run `SETUP.ps1` to ensure configs are still applied correctly.
