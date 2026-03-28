# Axion — Knowledge Management System

> Production-grade Obsidian vault template combining ACE Framework effort intensity, typed frontmatter schema, live Bases views, and AI-native scripting.

[![Version](https://img.shields.io/badge/version-5.0.0-indigo)]() [![Obsidian](https://img.shields.io/badge/obsidian-1.9%2B-purple)]() [![License](https://img.shields.io/badge/license-MIT-green)]()

---

## Features

| Feature | What It Does |
|---------|-------------|
| **Command Center** | `Home.md` — live task + effort dashboard |
| **Effort Intensity** | 4-state projects: On / Ongoing / Simmering / Sleeping |
| **Task Capture** | `Cmd+T` — 3 modes, zero friction |
| **Bases Views** | 7 typed Obsidian Bases (projects, tasks, people, health…) |
| **AI Scripts** | Claude + Gemini CLI + in-note `Cmd+Shift+A` |
| **CLAUDE.md Gen** | Auto-generates project context for Claude Code |

---

## Quick Start

1. **Clone** and open the folder in Obsidian (**File → Open folder as vault**).
2. **Run setup** from the vault root:

   | Platform | Command |
   |----------|---------|
   | **Windows (PowerShell)** | `.\99 - Meta\00 - Settings\SETUP.ps1` |
   | **Windows (CMD)** | `99 - Meta\00 - Settings\SETUP.bat` |
   | **macOS / Linux** | `bash "99 - Meta/00 - Settings/SETUP.sh"` *(needs `curl` + `jq`)* |

3. **Restart Obsidian**, install the **Vauxhall** theme if prompted, configure **Templater** script folder → `99 - Meta/00 - Settings/00 - Scripts/`, and wire **QuickAdd** per `99 - Meta/00 - Settings/quickadd-config.md`.

4. **Folder icons (optional):** Remix SVGs can be large; after clone you can run the PowerShell icon scripts or use Iconize’s built-in Remix download. See [SETUP-AND-GIT.md](99%20-%20Meta/00%20-%20Settings/SETUP-AND-GIT.md).

5. **Font (optional):** [install-jetbrains-mono-nerd-font.ps1](99%20-%20Meta/00%20-%20Settings/install-jetbrains-mono-nerd-font.ps1) or install JetBrains Mono Nerd Font manually.

---

## Documentation

| Guide | What it’s for |
|-------|----------------|
| **[SETUP-AND-GIT.md](99%20-%20Meta/00%20-%20Settings/SETUP-AND-GIT.md)** | First-time setup, icons, fonts, script order |
| **[COMMIT-GUIDE.md](99%20-%20Meta/00%20-%20Settings/COMMIT-GUIDE.md)** | What to **commit** vs. skip (script-regenerable assets) |
| **[HOW-TO-GUIDE.md](99%20-%20Meta/01%20-%20Core/HOW-TO-GUIDE.md)** | Daily workflow, Home.md, efforts, tasks |
| **[ICONIZE-TROUBLESHOOTING.md](99%20-%20Meta/00%20-%20Settings/ICONIZE-TROUBLESHOOTING.md)** | Iconize / Remix icon pack issues |
| **[GIT-STRATEGY.md](GIT-STRATEGY.md)** | Branching & product vs. personal data |

---

## Folder Structure

```
00 - Maps of Content/   Home.md — Command Center
01 - Inbox/             Capture zone
02 - Projects/
  _on/                  🔥 Max 3 — daily drivers
  _ongoing/             ♻️ Recurring
  _simmering/           〰️ Background
  _sleeping/            💤 Paused
03–05/                  Areas · Resources · Permanent
06 - Daily/             Daily · Weekly · Monthly
08 - Integration/       Bases + AI Scripts
99 - Meta/              Templates · Scripts · Settings
```

---

## Versioning

Follows [Semantic Versioning](https://semver.org/). See [CHANGELOG.md](99%20-%20Meta/01%20-%20Core/CHANGELOG.md).

- **MAJOR** — breaking structural changes (folder renames, schema changes)
- **MINOR** — new features (scripts, templates, bases)
- **PATCH** — fixes, copy, non-breaking tweaks

## License

MIT
