# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

A collection of reusable skill modules for Claude Code and GitHub Copilot. Each skill is a Markdown file (`SKILL.md`) that instructs an AI agent how to perform a specialized multi-phase workflow (e.g., generating changelogs, finding dead code, writing documentation).

## Installation

```bash
# Unix/macOS
./install.sh

# Windows (PowerShell)
./install.ps1
```

These scripts copy each `skills/<name>/` directory into `~/.claude/skills/` and `~/.copilot/skills/`.

## Skill Structure

Each skill lives in `skills/<skill-name>/SKILL.md` with optional `evals/evals.json` for test cases.

A `SKILL.md` file contains:
- **YAML frontmatter** — `name`, `description`, `tools` (list of Claude tools the skill may invoke)
- **Numbered phases** — Each phase has a title, step-by-step instructions, bash commands to run, and outcome decisions
- **Output section** — Specifies what the skill produces and how to summarize results to the user

## Architectural Conventions

**Skill design principles:**
- Skills must be **idempotent** — re-running should not corrupt existing files. Use `Edit` over `Write` when updating existing content.
- Skills use **graceful degradation** — if an optional CLI tool (e.g., `vulture`, `tsc`) is unavailable, fall back to grep-based analysis.
- Skills are **framework-aware** — e.g., `find-dead-code` knows not to flag Spring `@Bean` methods or DI-injected classes as dead.
- Skills support **monorepos** — detect multi-package layouts and apply per-package logic when appropriate.
- **Deduplication** is required — skills that append to existing files must check for existing entries before writing.

**Evals (`evals/evals.json`):**
- Array of `{ "description", "setup", "assertions[] }` objects
- `setup` contains shell commands to create a test environment
- `assertions` are plain-language statements verified by the skill creator tooling

## Current Skills

| Skill              | File                               | Purpose                                                  |
|--------------------|------------------------------------|----------------------------------------------------------|
| `changelog`        | `skills/changelog/SKILL.md`        | Generate/update CHANGELOG.md from git history            |
| `document-project` | `skills/document-project/SKILL.md` | Create README + `/docs` structure                        |
| `find-dead-code`   | `skills/find-dead-code/SKILL.md`   | Find unused functions, classes, imports across languages |

`skills/improve-logging/` exists as a placeholder with no `SKILL.md` yet.

## Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md` following the phase-based format of existing skills.
2. Add `evals/evals.json` with at least 3–5 test scenarios covering main cases.
3. The skill will be picked up automatically by `install.sh`/`install.ps1` on next run.
