# Cloud KMS — Knowledge Management System

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

```bash
git clone https://github.com/YOUR_USERNAME/cloud-kms-product.git
# Open as Obsidian vault → File → Open Vault → select folder
bash "99 - Meta/00 - Settings/SETUP.sh"
```

See [HOW-TO-GUIDE.md](99%20-%20Meta/01%20-%20Core/HOW-TO-GUIDE.md) for full setup and daily workflow.

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
