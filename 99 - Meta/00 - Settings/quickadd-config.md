---
type: meta
---
# ⚡ QuickAdd — Full Config

## Plugin Requirements
- [ ] **QuickAdd** — installed & enabled
- [ ] **Templater** — user scripts folder → `99 - Meta/00 - Settings/00 - Scripts/`
- [ ] API keys in `~/.zshrc` (Anthropic + Gemini)

---

## Macros to Register

### 1 · New Task `Cmd+T`
| Field | Value |
|-------|-------|
| Type | Macro → Templater |
| Script | `99 - Meta/00 - Settings/00 - Scripts/quick-task.js` |
| Palette | ✅ On |
| Hotkey | `Cmd+T` |

**What it does:** Prompts → Quick daily task / Project task / Standalone task note

---

### 2 · Ask AI `Cmd+Shift+A`
| Field | Value |
|-------|-------|
| Type | Macro → Templater |
| Script | `99 - Meta/00 - Settings/00 - Scripts/ai-ask.js` |
| Palette | ✅ On |
| Hotkey | `Cmd+Shift+A` |

---

### 3 · Change Effort `Cmd+Shift+E`
| Field | Value |
|-------|-------|
| Type | Macro → Templater |
| Script | `99 - Meta/00 - Settings/00 - Scripts/move-effort.js` |
| Palette | ✅ On |
| Hotkey | `Cmd+Shift+E` |

**What it does:** Opens from any project note → moves it to On / Ongoing / Simmering / Sleeping

---

### 4 · Generate CLAUDE.md
| Field | Value |
|-------|-------|
| Type | Macro → Templater |
| Script | `99 - Meta/00 - Settings/00 - Scripts/generate-claude-md.js` |
| Palette | ✅ On |
| Hotkey | *(optional)* |

---

## Full Hotkey Map

| Hotkey | Action |
|--------|--------|
| `Cmd+D` | New Daily Note (Periodic Notes) |
| `Cmd+T` | New Task |
| `Cmd+Shift+A` | Ask AI |
| `Cmd+Shift+E` | Change Effort Intensity |
| `Cmd+Shift+N` | New Note (Templater) |
| `Cmd+P` | Command Palette (anything else) |
