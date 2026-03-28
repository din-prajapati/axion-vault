# Changelog

All notable changes to Axion follow [Semantic Versioning](https://semver.org/).

---

## [5.0.0] - 2026-03-14

### Added
- **Effort Intensity System** — 4-state project folders: `_on` / `_ongoing` / `_simmering` / `_sleeping` (from ACE Framework)
- **Command Center** — rebuilt `Home.md` with ACE-style collapsible callouts + live Dataview task pull
- **`quick-task.js`** — `Cmd+T` macro with 3 capture modes (daily / project / standalone)
- **`move-effort.js`** — `Cmd+Shift+E` script to move projects between intensity folders + update frontmatter
- **`tasks.base`** — Obsidian Bases view for standalone task notes
- **Weekly Review Template** — full effort intensity check with live queries
- **Updated Daily Template** — pulls On-project tasks via collapsible Dataview callout
- **4 Sample Projects** — one per intensity level, demonstrates live queries
- **HOW-TO-GUIDE.md** — 11-part operational manual inside the vault
- **Git structure** — branching strategy, `.gitignore`, `CONTRIBUTING.md`

### Changed
- Project template: added `intensity` and `rank` frontmatter fields
- `_active/` → `_on/` · `_backlog/` → `_ongoing/` + `_simmering/` + `_sleeping/`
- `MOC - Projects.md` — rebuilt with per-intensity Dataview views + open task query
- `quickadd-config.md` — updated with 4 macros and full hotkey map
- `Bases Hub.md` — added `tasks.base` entry

### Removed
- `_active/` and `_backlog/` project folders (replaced by 4-intensity system)

---

## [4.0.0] - 2026-03-13

### Added
- `ai-ask.js` — in-note Claude/Gemini ask macro (`Cmd+Shift+A`)
- `generate-claude-md.js` — auto-generates project CLAUDE.md for Claude Code
- `kms-claude.sh` / `kms-gemini.sh` / `kms-ask.sh` — CLI wrappers
- QuickAdd macro config (`quickadd-config.md`)

---

## [3.0.0] - 2026-03-12

### Added
- 6 Bases files: projects · people · meetings · books · content · health
- `SETUP.sh` one-command vault activator
- `periodic-notes.json` + `style-settings.json` plugin configs
- Vauxhall theme config (Indigo, JetBrains Mono Nerd Font)

---

## [2.0.0] - 2026-03-11

### Added
- Full PARA-adjacent folder structure (00–99)
- Typed frontmatter schema (type, status, priority, area, deadline)
- All core templates: Daily · Weekly · Monthly · Project · Person · Meeting · Book · Content

---

## [1.0.0] - 2026-03-10

### Added
- Initial vault scaffold
- Home.md dashboard (static)
- Basic Dataview queries
