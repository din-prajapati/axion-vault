# Axion — How to Use Guide
**Version 5.0 · Hybrid ACE + Axion**

---

## Part 1 — System Overview

### Philosophy

Axion runs on three layers:

```
CAPTURE → EXECUTE → KNOW
   01         02       05
 Inbox    Projects  Permanent
```

- **Capture** everything fast, process deliberately
- **Execute** through Efforts — not project lists
- **Know** by building permanent notes from project outcomes

### The Effort Intensity Model (from ACE Framework)

Instead of "active vs backlog", every project lives in **one of four states**:

| Folder | Intensity | Rule |
|--------|-----------|------|
| `_on` | 🔥 On | Max **3 projects**. Your daily drivers. |
| `_ongoing` | ♻️ Ongoing | Recurring responsibilities. No sprint pressure. |
| `_simmering` | 〰️ Simmering | Alive but waiting. Revisit weekly. |
| `_sleeping` | 💤 Sleeping | Intentionally paused. Zero guilt. |

> **The key insight:** You don't abandon projects — you **adjust their temperature**. Moving a project to Simmering is a decision, not a failure.

---

## Part 2 — Command Center (Home.md)

### How to Read It

Open `Home.md` and you'll see **four collapsed sections**, each a separate headspace:

```
🔥 Today          → what needs immediate attention
🎯 Efforts        → where your projects are parked
✅ Open Tasks     → live task pull from project notes
📡 Radar          → people, meetings, recent changes
```

All sections are **collapsible callouts** — expand only what you need.

### Daily Start Routine (3 minutes)

1. Open `Home.md` (bookmark it or set as startup note)
2. Scan **Overdue** callout — anything red?
3. Check **Inbox** callout — anything to process?
4. Expand **🔥 On** — pick your day's work from live tasks
5. Write your **Top 3** directly in the Today callout

### What Each Section Shows

**Today section**
- `Top 3 Priorities` — manual. You fill this in each morning.
- `Overdue` — auto. Any project with a past deadline, not sleeping.
- `Inbox` — auto. Unprocessed inbox items (status = unprocessed).

**Efforts section**
- Live Dataview queries pulling from `02 - Projects/_on`, `_ongoing`, `_simmering`, `_sleeping`
- Sorted by `rank` field — higher number = higher priority
- 🔥 On and ♻️ Ongoing expanded by default; Simmering/Sleeping collapsed

**Open Tasks section**
- Pulls actual `- [ ]` checkboxes from project files
- Grouped by project link — click the project name to open it
- You tick tasks directly in Home.md — they sync back to the source file

**Radar section**
- Collapsed by default. Use for weekly reviews, not daily.

---

## Part 3 — Creating & Moving Projects

### Create a New Project

1. Navigate to the target effort folder:
   `02 - Projects/_on/` (or `_ongoing`, `_simmering`)
2. Create new note → apply template `(TEMPLATE) Project.md`
3. Fill in frontmatter:

```yaml
type: project
title: Your Project Title
status: Planning          # Planning / In Progress / Done
intensity: on             # on / ongoing / simmering / sleeping
rank: 7                   # 1–10, higher = higher priority
priority: High            # High / Medium / Low
area: Work                # Work / Health / Finance / Creative / Personal
deadline: "2026-04-30"    # or "" if none
goal: "One sentence: what does success look like?"
```

### Move a Project's Intensity

**Method A — Hotkey (recommended)**

1. Open any project note
2. Press `Cmd+Shift+E`
3. Pick the new intensity from the list
4. Script moves the file + updates the `intensity` field automatically

**Method B — Manual**

1. Move the file to the correct folder (`_on`, `_ongoing`, etc.)
2. Update `intensity:` field in frontmatter to match

### Effort Rules to Live By

- 🔥 **On: max 3 projects.** If you want to add a 4th, you must move one out.
- ♻️ **Ongoing: no limit**, but be honest. Ongoing ≠ procrastinating on an On project.
- 〰️ **Simmering: no schedule.** Just means "I haven't forgotten you."
- 💤 **Sleeping: no guilt.** Better than deleting. You can always wake it.

---

## Part 4 — Task Management

### Three Ways to Create Tasks

**Option 1 — Inline in Daily Note** (fastest)
- Open daily note → add `- [ ] Task` anywhere in the file
- Visible in Home.md under "Today's Daily Tasks"

**Option 2 — Hotkey capture** `Cmd+T`
- Press `Cmd+T` from anywhere
- Choose mode:
  - **Quick task** → appended to today's daily note
  - **Project task** → pick a project → appended to its Tasks section
  - **Standalone task note** → creates a typed note in Inbox

**Option 3 — Directly in project note**
- Open any project in `_on` or `_ongoing`
- Add `- [ ] Task` under `## ✅ Tasks`
- It appears automatically in `Home.md` task views

### How Dataview Task Queries Work

Home.md uses `TASK` queries — they pull live checkboxes from files:

```
Home.md shows: - [ ] Finalise wireframes
                ↑
This is the actual checkbox in: 02 - Projects/_on/Website Redesign.md
Tick it in Home.md → ticked in source file too.
```

> **Important:** Dataview task queries only display tasks from folders in the query. Standalone task notes (type = task) appear in `tasks.base`, not in the Home task callout.

### Task Lifecycle

```
Cmd+T → captured in daily note / project
  ↓
Ticked (completed = true) in source file
  ↓
Disappears from open task views
  ↓
Appears in Weekly Review "Completed" query
```

### The tasks.base (Structured Task Notes)

For complex tasks that need their own note:
- Use Standalone mode in `Cmd+T`
- File lands in `01 - Inbox/` with `type: task`
- Visible in `08 - Integration/_bases/tasks.base`
- Fields: title · status · priority · project · area · due

Use this for tasks that need context, dependencies, or sub-steps.

---

## Part 5 — Daily Workflow

### Morning (5 min)

```
1. Cmd+D          → open today's Daily Note
2. Check Home.md  → scan Overdue + Inbox
3. Top 3          → write your three priorities
4. Time blocks    → fill in what you'll work on when
```

### During the Day

```
Cmd+T             → capture any task that lands
Cmd+Shift+A       → ask AI about the current note
Open project      → tick tasks as you complete them
```

> Home.md auto-refreshes Dataview queries — no manual sync needed.

### Evening (5 min)

```
1. Open Daily Note
2. Fill End-of-Day metrics (energy, focus, wins)
3. Write Tomorrow's Top 3
4. Review Inbox → process anything from the day
```

---

## Part 6 — Weekly Review

### When: Every Sunday (30 min)

**Step 1 — Open Weekly Template**
Create new note in `06 - Daily/Weekly/` → apply `(TEMPLATE) Weekly.md`

**Step 2 — Effort Intensity Check**
The weekly template shows live queries for all four effort folders. For each 🔥 On project, ask:
- Is this still the right focus?
- Should anything in Simmering be promoted to On?
- Anything in On that's stalled → move to Simmering?

**Step 3 — Make Intensity Moves**
Open relevant project notes → `Cmd+Shift+E` → move.

**Step 4 — Rank Adjustment**
Update `rank:` fields if priorities have shifted. Range: 1–10.

**Step 5 — Review Completed Tasks**
The Weekly template pulls `TASK WHERE completed AND modified last 7 days`.

**Step 6 — Next Week Focus**
Write 3 priority statements. Not tasks — directions.

---

## Part 7 — AI Integration

### Quick AI Ask `Cmd+Shift+A`

Opens from any note — asks Claude or Gemini a question about it. Response appended at the bottom as a dated section.

Use it for:
- "What are the next actions in this project?"
- "Summarise this meeting note"
- "What risks am I not seeing?"
- "Turn these notes into a brief"

### CLI Scripts (Terminal)

```bash
# From vault root — ask Claude about a project
./08\ -\ Integration/_scripts/kms-claude.sh \
  --file "02 - Projects/_on/Website Redesign.md" \
  --prompt "What tasks are blocking progress?"

# Route to Gemini
./08\ -\ Integration/_scripts/kms-ask.sh \
  --tool gemini \
  --file "02 - Projects/_on/Q2 Content Strategy.md"
```

### CLAUDE.md Auto-Generator

When you create a new project note:
- The template auto-runs `generate-claude-md.js`
- Creates a `CLAUDE.md` in the same folder as the project
- Contains: title, goal, status, area, deadline — formatted for Claude Code

Useful if you're using Claude Code to work on deliverables related to that project.

---

## Part 8 — Bases (Filtered Views)

| Base | What it shows | Open from |
|------|---------------|-----------|
| `projects.base` | All projects with status/intensity/priority | Bases Hub |
| `tasks.base` | All standalone task notes | Bases Hub |
| `people.base` | All contacts + last contact date | Bases Hub |
| `meetings.base` | All meetings + attendees | Bases Hub |
| `books.base` | Reading list with status/rating | Bases Hub |
| `content.base` | Content pipeline by platform | Bases Hub |
| `health.base` | Daily notes health metrics | Bases Hub |

Access all bases: `08 - Integration/_bases/Bases Hub.md`

**Tip:** Bases are Obsidian's native database views (1.9+). They work without Dataview — faster, filterable, sortable directly in UI.

---

## Part 9 — Hotkey Reference

| Hotkey | Action |
|--------|--------|
| `Cmd+D` | New Daily Note |
| `Cmd+T` | New Task (3 modes) |
| `Cmd+Shift+A` | Ask AI about current note |
| `Cmd+Shift+E` | Change project effort intensity |
| `Cmd+Shift+N` | New note from template |
| `Cmd+P` | Command palette |

---

## Part 10 — Folder Quick Reference

```
00 - Maps of Content/
  Home.md                ← Command Center (start here daily)

01 - Inbox/
  PROCESS.md             ← Inbox processing rules
  _quick/ _ideas/ _links/ _media/

02 - Projects/
  _on/                   ← 🔥 Max 3. Daily drivers.
  _ongoing/              ← ♻️ Recurring. No sprint pressure.
  _simmering/            ← 〰️ Alive but waiting.
  _sleeping/             ← 💤 Paused. No guilt.
  MOC - Projects.md      ← All projects in one view

03 - Areas/              ← Work / Health / Finance / Creative / Relationships / Meetings
04 - Resources/          ← Learning / Media / Reference
05 - Permanent/          ← Atomic evergreen notes
06 - Daily/              ← Daily / Weekly / Monthly

08 - Integration/
  _bases/                ← Bases Hub + all .base files
  _scripts/              ← kms-claude.sh · kms-gemini.sh · kms-ask.sh

99 - Meta/
  00 - Settings/
    00 - Scripts/        ← quick-task.js · move-effort.js · ai-ask.js · generate-claude-md.js
    quickadd-config.md   ← How to wire QuickAdd macros
  02 - Templates/        ← All (TEMPLATE) *.md files
```

---

## Part 11 — Setup Checklist

Run once when you first open the vault:

- [ ] Run `99 - Meta/00 - Settings/SETUP.sh` from terminal (copies theme + plugin configs)
- [ ] Set Templater user scripts folder → `99 - Meta/00 - Settings/00 - Scripts/`
- [ ] Wire QuickAdd macros from `quickadd-config.md`
- [ ] Add API keys to `~/.zshrc`:
  ```bash
  export ANTHROPIC_API_KEY="sk-ant-..."
  export GEMINI_API_KEY="AIza..."
  ```
- [ ] `chmod +x "08 - Integration/_scripts/"*.sh`
- [ ] Open `Home.md` → pin it as startup note
- [ ] Create your first project in `_on` or `_ongoing`
- [ ] Test `Cmd+T` → confirm task capture works

---

## Quick-Start: First Day

```
1. Open Home.md
2. Cmd+D → write today's Top 3
3. Cmd+T → capture one real task
4. Create one project in 02 - Projects/_on/
5. Cmd+Shift+A on that project → ask "What are my next actions?"
6. Tick a task from Home.md
```

That's the full loop. Everything else is just doing it again.
