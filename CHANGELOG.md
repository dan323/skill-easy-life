# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- `changelog` skill — generates and updates CHANGELOG.md files from git history, with Keep a Changelog formatting, monorepo support, and deduplication
- `document-project` skill — creates project documentation including a root README and /docs directory with linked pages
- `find-dead-code` skill — finds unused functions, classes, variables, imports, and types across a codebase, with support for DI frameworks
- Eval set for changelog skill (`skills/changelog/evals/evals.json`)
- `install.sh` and `install.ps1` — installation scripts to deploy skills to `~/.claude/skills/` and `~/.copilot/skills/`
- `.claude/CLAUDE.md` — repository guidance file for Claude Code
- `improve-logging` skill — audits logging quality and produces prioritised recommendations: remove sensitive/noisy logs, add missing logs, fix log levels, improve messages, enforce consistency
- Eval sets for `document-project`, `find-dead-code`, and `improve-logging` skills

### Changed
- `improve-logging` skill: added required-fields definition (`request_id`, `user_id`, `error`), HTTP status code → log level mapping (4xx=WARN, 5xx=ERROR), precise exception handling rules (re-raise→ERROR, handled→WARN, swallowed→flag as missing), and concrete grep patterns for detecting important operations by function name
