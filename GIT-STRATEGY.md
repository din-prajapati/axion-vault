# Git Strategy — Cloud KMS

Two repos. One product. One life.

---

## Overview

```
cloud-kms-product/     ← PUBLIC (or private for now)
  Template vault       ← What you ship
  Branching strategy   ← feature/* → develop → main
  Tagged releases      ← v5.0.0, v5.1.0…

cloud-kms-vault/       ← PRIVATE always
  Your actual notes    ← Everything you live in
  Daily commits        ← Backup + history
  Pulls from product   ← Update vault when template ships
```

---

## Repo 1 — Product (`cloud-kms-product`)

### Branch Model

```
main          ← stable only · tagged releases
  └─ develop  ← integration · always green
       ├─ feature/*   ← new capabilities
       ├─ fix/*       ← broken queries/scripts
       └─ release/*   ← version bump + changelog
```

### Day-to-Day: Adding a Feature

```bash
# Start from develop
git checkout develop && git pull
git checkout -b feature/kanban-task-view

# Build it …

# Commit (conventional commits)
git add .
git commit -m "feat: add kanban.base for task board view"

# Merge back
git checkout develop
git merge feature/kanban-task-view
git push origin develop
git branch -d feature/kanban-task-view
```

### Releasing a Version

```bash
# Cut release branch
git checkout develop
git checkout -b release/5.1.0

# Bump version in README badge + CHANGELOG
git commit -m "chore: bump to v5.1.0"

# Ship to main
git checkout main
git merge release/5.1.0
git tag -a v5.1.0 -m "v5.1.0: Kanban view + effort sort"
git push origin main --tags

# Back-merge to develop
git checkout develop
git merge main
git branch -d release/5.1.0
```

### Commit Prefixes

| Prefix | Use |
|--------|-----|
| `feat:` | New template, script, base, workflow |
| `fix:` | Broken query, wrong path, template error |
| `docs:` | README, HOW-TO, CHANGELOG |
| `refactor:` | Rename/restructure, same behaviour |
| `chore:` | .gitignore, SETUP.sh, config-only |

### What Belongs Here

✅ Templates, scripts, `.base` files, CLI wrappers, Obsidian config  
✅ Sample/demo notes (the 4 example projects)  
❌ Real notes, personal projects, contacts, daily notes  
❌ `workspace.json`, plugin `data.json`, API keys  

---

## Repo 2 — Vault (`cloud-kms-vault`)

### Philosophy

This is your **backup + history**, not a code project. Commits are cheap. Commit often.

### Branch Model

```
main          ← your vault. One branch. That's it.
```

No feature branches. No releases. Just a rolling personal history.

### Daily Commit Habit

```bash
cd ~/path/to/your-vault

# Quick end-of-day commit
git add .
git commit -m "daily: $(date +%Y-%m-%d) — notes + projects"
git push origin main
```

Or use the automation script below.

### Auto-Commit Script

Save as `~/bin/kms-vault-sync.sh`:

```bash
#!/bin/bash
# kms-vault-sync.sh — auto commit + push vault
VAULT="$HOME/path/to/your-vault"   # ← update this path

cd "$VAULT" || exit 1

if [[ -n $(git status --porcelain) ]]; then
  git add .
  git commit -m "sync: $(date '+%Y-%m-%d %H:%M') — auto"
  git push origin main
  echo "✅ Vault synced $(date '+%H:%M')"
else
  echo "— Nothing to commit"
fi
```

```bash
chmod +x ~/bin/kms-vault-sync.sh

# Optional: run every hour with cron
crontab -e
# Add: 0 * * * * ~/bin/kms-vault-sync.sh >> ~/kms-sync.log 2>&1
```

### Commit Message Conventions (vault)

No strict rules — just be consistent enough to search later:

```
daily: 2026-03-14 — website project tasks
weekly: W11 review + effort moves
note: permanent note on habit formation
meeting: client call + follow-up tasks
sync: 2026-03-14 15:30 — auto
```

### What to Commit

✅ All your notes (`.md` files)  
✅ Obsidian config (`appearance.json`, `hotkeys.json`, `community-plugins.json`)  
✅ Plugin binaries (optional — larger repo but faster fresh clone)  
❌ `workspace.json`, `cache`, `graph.json` (machine-specific)  
❌ `.env`, API keys, secrets  

---

## Keeping Vault in Sync with Product Releases

When you ship a new product version, pull the improvements into your personal vault.

### Option A — Selective File Copy (recommended)

Best when your vault has diverged (you've customised things):

```bash
PRODUCT="$HOME/dev/cloud-kms-product"
VAULT="$HOME/path/to/your-vault"

# Pull latest product
cd "$PRODUCT" && git pull origin main

# Copy specific updated files
cp "$PRODUCT/99 - Meta/02 - Templates/(TEMPLATE) Project.md" \
   "$VAULT/99 - Meta/02 - Templates/"

cp "$PRODUCT/99 - Meta/00 - Settings/00 - Scripts/quick-task.js" \
   "$VAULT/99 - Meta/00 - Settings/00 - Scripts/"

cp "$PRODUCT/08 - Integration/_bases/tasks.base" \
   "$VAULT/08 - Integration/_bases/"

# Commit the update in vault
cd "$VAULT"
git add .
git commit -m "update: pull v5.1.0 templates + scripts from product"
```

### Option B — Git Subtree (advanced)

Treats the product repo as a subtree inside the vault — tracks it as a remote and can pull updates cleanly.

```bash
cd "$VAULT"

# Add product as a remote (one-time)
git remote add product https://github.com/YOUR_USERNAME/cloud-kms-product.git
git fetch product

# Pull product changes into a subfolder
git subtree pull \
  --prefix="99 - Meta/product-source" \
  product main \
  --squash \
  -m "update: pull product v5.1.0"
```

Use Option A unless you're comfortable with subtree conflicts.

---

## Initial Setup (run once)

### Product Repo

```bash
cd ~/dev
git clone https://github.com/YOUR_USERNAME/cloud-kms-product.git
cd cloud-kms-product

# Create develop branch
git checkout -b develop
git push -u origin develop

# Protect main on GitHub:
# Settings → Branches → Add rule → main
# ✅ Require pull request before merging
# ✅ Require 1 approval (or disable for solo)
```

### Personal Vault Repo

```bash
cd ~/path/to/your-vault

# Init + first commit
git init
git branch -m main

# Copy .gitignore from this guide (or from product repo)

git add .
git commit -m "init: Cloud KMS v5.0 vault"

# Create private repo on GitHub, then:
git remote add origin git@github.com:YOUR_USERNAME/cloud-kms-vault.git
git push -u origin main
```

---

## GitHub Repo Settings

### Product Repo
| Setting | Value |
|---------|-------|
| Visibility | Public or Private |
| Default branch | `develop` |
| Branch protection (main) | ✅ Require PR |
| Tags | `v5.0.0`, `v5.1.0`… |
| Releases | Create GitHub Release per tag |

### Vault Repo
| Setting | Value |
|---------|-------|
| Visibility | **Private** always |
| Default branch | `main` |
| Branch protection | None needed |
| Releases | None |

---

## Quick Reference

```bash
# ── Product: new feature ──────────────────────────────────────
git checkout develop && git checkout -b feature/my-feature
# … build …
git add . && git commit -m "feat: my feature"
git checkout develop && git merge feature/my-feature

# ── Product: ship release ─────────────────────────────────────
git checkout -b release/5.1.0
git commit -m "chore: bump to v5.1.0"
git checkout main && git merge release/5.1.0
git tag -a v5.1.0 -m "v5.1.0" && git push origin main --tags
git checkout develop && git merge main

# ── Vault: daily sync ─────────────────────────────────────────
git add . && git commit -m "daily: $(date +%Y-%m-%d)" && git push

# ── Vault: pull product update ────────────────────────────────
# Copy changed files manually, then:
git add . && git commit -m "update: pull product v5.1.0"
```
