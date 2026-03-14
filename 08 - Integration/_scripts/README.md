# 🔧 Cloud KMS — Scripts

Shell wrappers that connect the vault to external AI tools.

## Scripts

| Script | Trigger | Purpose |
|--------|---------|---------|
| `kms-claude.sh` | CLI | Send text/file to Claude CLI, stream response |
| `kms-gemini.sh` | CLI | Send text/file to Gemini CLI, stream response |
| `kms-ask.sh` | CLI | Router — pick tool interactively or via flag |
| `kms-vault-export.sh` | CLI | Dump notes by type/tag to merged file |

## Setup

```bash
# 1. Make executable (run once from vault root)
chmod +x "08 - Integration/_scripts/"*.sh

# 2. Install CLIs (if not already)
npm install -g @anthropic-ai/claude-code   # Claude Code CLI
pip install google-generativeai             # Gemini CLI (or use `gemini` npm pkg)

# 3. Set API keys in your shell profile (~/.zshrc or ~/.bashrc)
export ANTHROPIC_API_KEY="sk-ant-..."
export GEMINI_API_KEY="AIza..."
```

## Usage

```bash
# Ask Claude a question
echo "Summarise this project" | ./kms-claude.sh

# Ask with a specific vault note as context
./kms-claude.sh --file "02 - Projects/_active/My Project.md"

# Router — choose tool at runtime
./kms-ask.sh --tool gemini --file "05 - Permanent/Some Note.md"

# Export all active projects to one file (for NotebookLM, etc.)
./kms-vault-export.sh --type project --status active
```

## QuickAdd Integration

These scripts are called by QuickAdd macros in Obsidian.
See: `99 - Meta/00 - Settings/quickadd-config.md`
