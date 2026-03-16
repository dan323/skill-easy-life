# agent-skills

A collection of reusable skill modules for [Claude Code](https://claude.ai/code) and GitHub Copilot. Each skill is a Markdown file that gives an AI agent detailed, phase-by-phase instructions for performing a specialized development task — generating changelogs, auditing logging, finding dead code, and more.

## Quick Start

```bash
# Unix / macOS
./scripts/install.sh

# Windows (PowerShell)
./scripts/install.ps1
```

Skills are copied to `~/.claude/skills/` and `~/.copilot/skills/` and become available immediately in your next Claude Code session.

## Skills

| Skill                                                  | What it does                                                  |
|--------------------------------------------------------|---------------------------------------------------------------|
| [`changelog`](skills/changelog/SKILL.md)               | Generate or update `CHANGELOG.md` from git history            |
| [`document-project`](skills/document-project/SKILL.md) | Create a root `README.md` and `/docs` pages for a project     |
| [`find-dead-code`](skills/find-dead-code/SKILL.md)     | Find unused functions, classes, imports, and variables        |
| [`improve-logging`](skills/improve-logging/SKILL.md)   | Audit log quality and produce prioritised fix recommendations |
| [`find-breaking-rest-api`](skills/find-breaking-rest-api/SKILL.md) | Detect breaking changes in REST APIs by comparing git history         |

## Documentation

- [Getting Started](docs/getting-started.md)
- [Architecture](docs/architecture.md)
- [Contributing a Skill](docs/contributing.md)
