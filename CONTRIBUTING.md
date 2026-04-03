# Contributing to Axion

---

## Branch Strategy

```
main                    ← stable releases only. Tagged.
  └─ develop            ← integration branch, always green
       ├─ feature/*     ← new features
       ├─ fix/*         ← bug fixes
       └─ release/*     ← release prep (version bump, changelog)
```

**Rules:**
- Never commit directly to `main`
- `develop` must pass self-review before merge
- `main` only receives merges from `release/*`
- Every merge to `main` gets a version tag: `v5.0.0`

---

## Feature Development Flow

```bash
# 1. Branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/tasks-kanban-view

# 2. Build the feature
# ... make changes ...

# 3. Commit with conventional commits
git add .
git commit -m "feat: add kanban base view for task board"

# 4. Merge back to develop
git checkout develop
git merge feature/tasks-kanban-view
git branch -d feature/tasks-kanban-view
```

---

## Conventional Commits

| Prefix | Use For |
|--------|---------|
| `feat:` | New template, script, base, or workflow |
| `fix:` | Broken Dataview query, wrong path, template error |
| `docs:` | README, HOW-TO-GUIDE, CHANGELOG updates |
| `refactor:` | Rename, restructure without changing behaviour |
| `chore:` | .gitignore, SETUP.sh, non-user-facing changes |

**Examples:**
```
feat: add weekly effort review template
fix: correct Dataview query path in Home.md tasks section
docs: update HOW-TO-GUIDE Part 4 task lifecycle
refactor: rename _active to _on across all templates
chore: update .gitignore to exclude workspace.json
```

---

## Release Process

```bash
# 1. Create release branch from develop
git checkout develop
git checkout -b release/5.1.0

# 2. Version bump + changelog
# - Update CHANGELOG.md with [5.1.0] section
# - Update version badge in README.md

# 3. Commit release prep
git commit -m "chore: bump version to 5.1.0"

# 4. Merge to main + tag
git checkout main
git merge release/5.1.0
git tag -a v5.1.0 -m "v5.1.0: Add kanban task view + weekly effort template"
git push origin main --tags

# 5. Merge back to develop
git checkout develop
git merge main
git branch -d release/5.1.0
```

---

## Versioning Rules

| Change Type | Version Bump | Example |
|-------------|-------------|---------|
| Folder renames, schema breaks | MAJOR (5.x → 6.0) | Rename `02 - Projects` |
| New script / template / base | MINOR (5.0 → 5.1) | Add `kanban.base` |
| Fix / copy / query correction | PATCH (5.0.0 → 5.0.1) | Fix broken Dataview path |

---

## What Belongs in This Repo

✅ **Include:**
- All templates (`99 - Meta/02 - Templates/`)
- All scripts (`99 - Meta/00 - Settings/00 - Scripts/`)
- All base definitions (`08 - Integration/_bases/*.base`)
- CLI scripts (`08 - Integration/_scripts/`)
- Obsidian config (`appearance.json`, `hotkeys.json`, `community-plugins.json`)
- Sample/demo notes only

❌ **Never include:**
- Real daily notes, personal projects, or contacts
- Plugin `data.json` (user-specific state)
- `workspace.json` / `workspace` (local UI layout)
- `.env` files or API keys
- Zip archives or build artifacts
