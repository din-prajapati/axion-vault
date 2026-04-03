---

## type: cowork
version: "2.0"
last_updated: 2026-03-13

# 🤖 Claude Cowork — Vault Brief

> **Purpose:** Hand this file to Claude at the start of any new session.
> Copy-paste the section relevant to your task, or paste the whole file.

---

## 1 · Vault Identity


| Key              | Value                                             |
| ---------------- | ------------------------------------------------- |
| Vault name       | Axion                                             |
| Owner            | 100xArch - Dinesh                                 |
| OS               | Mac + iPhone                                      |
| Theme            | Vauxhall (Indigo, Standard, Gradient Cyan/Purple) |
| Font             | JetBrains Mono Nerd Font Mono                     |
| Obsidian version | 1.9+ (Bases supported)                            |


---

## 2 · Folder Map

```
00 - Maps of Content  ← Home dashboard + area MOCs         [Mint]
01 - Inbox            ← All unprocessed capture             [Cyan]
  _quick / _links / _ideas / _media / PROCESS.md
02 - Projects         ← Active + backlog work units          [Light Blue]
  _active / _backlog / MOC - Projects.md
03 - Areas            ← Life domains                        [Blue]
  Work / Health / Finance / Creative / Relationships / Meetings
04 - Resources        ← Reference material                  [Violet]
  Learning / Media / Reference
05 - Permanent        ← Atomic evergreen notes              [Purple]
06 - Daily            ← Time-anchored notes                 [Magenta]
  Daily / Weekly / Monthly / Yearly
07 - Archives         ← Completed/dead content              [Hot Red]
08 - Integration      ← .base views + scripts               [Cool Cyan]
  _bases / _scripts
99 - Meta             ← System layer (DO NOT REORGANISE)    [Cool Gray]
  00 - Settings / 01 - Core / 02 - Templates / attachments
```

---

## 3 · Object Types (frontmatter `type:`)


| type        | Location                  | Key fields                              |
| ----------- | ------------------------- | --------------------------------------- |
| `home`      | 00 - Maps of Content/     | —                                       |
| `fleeting`  | 01 - Inbox/               | status, source, captured                |
| `project`   | 02 - Projects/            | status, priority, area, deadline        |
| `person`    | 03 - Areas/Relationships/ | role, company, last_contact, projects[] |
| `meeting`   | 03 - Areas/Meetings/      | date, people[], projects[]              |
| `content`   | 03 - Areas/Creative/      | platform, format, status, publish_date  |
| `book`      | 04 - Resources/Learning/  | author, status, rating                  |
| `permanent` | 05 - Permanent/           | —                                       |
| `daily`     | 06 - Daily/Daily/         | sleep, mood, energy, deep_work_hrs      |
| `weekly`    | 06 - Daily/Weekly/        | week                                    |
| `monthly`   | 06 - Daily/Monthly/       | income, expenses, savings               |
| `moc`       | anywhere                  | —                                       |


---

## 4 · Plugin Stack

### Phase 1 — Installed (from Cloud_KMS)

- Dataview · Templater · QuickAdd · Calendar
- Obsidian Icon Folder (Iconize) · Day Planner
- Admonition · Banners · Pexels Banner
- Style Settings · Editing Toolbar
- Smart Typography · Tag Wrangler
- Advanced Slides (Vauxhall CSS variant included)

### Phase 2 — Add Next

- Periodic Notes (for Weekly/Monthly/Yearly auto-creation)
- Smart Connections (Claude API key → in-vault AI search)

### Phase 3 — Later

- Kanban · Commander · Advanced URI

---

## 5 · CSS Snippets (enabled)

```
Colored Sidebar Items   ← 00-99 prefix → spectral gradient
Daily Note              ← cssclass: daily styling
Notebook Backgrounds    ← per-folder paper texture (CyanVoxel)
Daily Note Themes       ← day-of-week colour moods (CyanVoxel)
CyanVoxel's General Tweaks
retro-notebook-bg
Runescape / Minecraft   ← fun overlays (toggle as needed)
```

---

## 6 · Design Principles

1. **Inbox first** — everything enters `01 - Inbox`, exits weekly
2. **Type = structure** — every note has `type:` frontmatter; Bases and Dataview query by type
3. **Folders = life areas** — not topic trees; no deep nesting
4. **Bases for views** — databases live in `08 - Integration/_bases/`
5. **99 - Meta is sacred** — inheritance system + templates live here; Claude should not reorganise
6. **Vauxhall aesthetic** — dark, atmospheric, JetBrains Mono; new CSS goes into snippets, not inline

---

## 7 · Session Starters (copy-paste for Claude)

### Add a new template

```
Vault = Axion (see CLAUDE_COWORK.md §2–3 for context).
Create a new Templater template for type = "[TYPE]".
Save to: 99 - Meta/02 - Templates/(TEMPLATE) [Name].md
Follow the frontmatter schema in §3. Match Vauxhall dark aesthetic.
```

### Build a new Base view

```
Vault = Axion. Add a new Obsidian Bases .base file to:
08 - Integration/_bases/[name].base
Filter: type = "[type]", columns: [field1, field2, field3]
Also update the Bases Hub index: 08 - Integration/_bases/Bases Hub.md
```

### Fix/extend a Dataview query

```
Vault = Axion. This Dataview query in [file] isn't working:
[paste query]
Fields available: [list from §3]. Fix or extend it.
```

### Add an automation

```
Vault = Axion. Mac + iPhone. Plugins: Templater, QuickAdd, Periodic Notes.
I want to automate: [describe trigger + action].
Output: QuickAdd macro config OR Templater script for 99 - Meta/00 - Settings/00 - Scripts/
```

---

## 8 · Pending Work (pick up here)

- Copy existing Meta inheritance system from `99_-_Meta.zip` → `99 - Meta/01 - Core/` ✅ already present in v2
- Configure Periodic Notes plugin → `99 - Meta/00 - Settings/02 - Plugin Configs/periodic-notes.json` ✅ 2026-03-13
- Create 6 `.base` files in `08 - Integration/_bases/` (all columns configured) ✅ 2026-03-13
- Rename live vault folders: 01→02, 02→03, 03→04, 04→05, 05→01 (Inbox) — **do manually in Obsidian**
- `SETUP.sh` copies `Colored Sidebar Items.css` → `.obsidian/snippets/` automatically ✅ 2026-03-13
- Style Settings config: Indigo · Standard · Gradient Cyan/Purple → `02 - Plugin Configs/style-settings.json` ✅ 2026-03-13
- `_scripts/` starter kit — `kms-claude.sh`, `kms-gemini.sh`, `kms-ask.sh` ✅ 2026-03-13
- `CLAUDE.md` auto-generator — `generate-claude-md.js` + wired into Project template ✅ 2026-03-13
- QuickAdd → AI macro — `ai-ask.js` + `quickadd-config.md` setup guide ✅ 2026-03-13
- Install Smart Connections (Phase 2) — manual, needs API key
- Install Periodic Notes (Phase 2) — manual via Community Plugins
- `.cursorrules` template (Phase 3)
- NotebookLM export macro (Phase 3)

---

## 9 · Previous Session Transcript

> Path: `/mnt/transcripts/2026-03-13-09-34-46-obsidian-vault-design-cyanvoxel.txt`
> Use this to restore full context (CyanVoxel analysis, vault philosophy, Notion vs Capacities synthesis).

