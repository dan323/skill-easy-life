[← Back to README](../README.md)

# Getting Started

## Prerequisites

- **Claude Code** (`claude` CLI) — [install guide](https://claude.ai/code) — or **GitHub Copilot** with skills support
- **Git** (required by several skills at runtime)
- **Bash** (Unix) or **PowerShell** (Windows) to run the installer

## Install

1. Clone the repository:

   ```bash
   git clone https://github.com/your-org/agent-skills.git
   cd agent-skills
   ```

2. Run the installer for your platform:

   ```bash
   # Unix / macOS
   ./scripts/install.sh

   # Windows (PowerShell)
   ./scripts/install.ps1
   ```

   The script copies every skill folder from `skills/` into:
   - `~/.claude/skills/` (Claude Code)
   - `~/.copilot/skills/` (GitHub Copilot)

3. Verify by starting a new Claude Code session and asking it to use one of the skills:

   ```
   Generate a changelog for this project
   ```

## First Use

Skills trigger automatically when Claude recognises a matching request — you do not need to name the skill explicitly. For example:

| You say | Skill triggered |
|---|---|
| "Generate a changelog" | `changelog` |
| "Document this project" | `document-project` |
| "Find dead code" | `find-dead-code` |
| "Review our logging" | `improve-logging` |

Each skill produces output in your current working directory (report files, updated `CHANGELOG.md`, new `README.md`, etc.).

## Updating

To pick up new or updated skills, pull the latest changes and re-run the installer:

```bash
git pull
./scripts/install.sh   # or install.ps1
```

---

## See Also

- [Architecture](architecture.md) — how skills are structured and how they work
- [Contributing a Skill](contributing.md) — how to write and test your own skill
