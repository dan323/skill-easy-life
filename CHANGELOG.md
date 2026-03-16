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
- `find-breaking-rest-api` skill — compares git history to identify breaking REST API changes; handles multi-file routers (Express, Flask, FastAPI, Spring Boot), shared request/response schemas, auth requirement changes, path prefix moves, and OpenAPI/Swagger specs
- Eval set for `find-breaking-rest-api` skill with scenarios covering multi-file Express routers, path prefix changes, and endpoint removal
- `find-dead-code` eval: Spring `@Configuration` class scenario — verifies that `@Bean` factory methods are excluded (called via CGLIB proxy) while genuinely dead private helpers are correctly flagged at high confidence

### Changed
- `improve-logging` skill: added required-fields definition (`request_id`, `user_id`, `error`), HTTP status code → log level mapping (4xx=WARN, 5xx=ERROR), precise exception handling rules (re-raise→ERROR, handled→WARN, swallowed→flag as missing), and concrete grep patterns for detecting important operations by function name
- `improve-logging` skill: added new "Logs to remove" phase covering sensitive-data leakage (passwords, tokens, API keys), debug artifacts (`console.log`, `print`, `fmt.Println`), log spam inside tight loops, and redundant log calls; report output reordered so Remove findings appear first as the highest-priority security concern
- `CLAUDE.md` and `README.md`: registered `find-breaking-rest-api` in the skills table; noted that `find-breaking-api` is superseded by the narrower REST-only skill
- `find-breaking-rest-api` v3.0: rewrote as a report-focused skill — replaced 5-phase detection scaffolding with concise investigation instructions; report format now requires a summary table (endpoint / change / severity / client action), HIGH/MEDIUM/LOW severity on every breaking change, an explicit "Files traced (unchanged)" methodology header, and a "Client action required" field per change entry; eval suite extended with "unchanged files" scenarios (FastAPI, Spring Boot, Flask) where only the schema/DTO file is in the diff
- `docs/architecture.md`: expanded directory tree to show actual skill names and correct per-skill layout; fixed malformed tree nesting
- `CLAUDE.md`: added `improve-logging` to skills table; removed stale placeholder note
- `brainstorm` skill — reads the entire project and produces 5 specific, ranked ideas (feature or improvement) with effort estimate and a concrete first step for each; ideas are ranked by value/effort ratio and grounded in what's actually in the codebase; eval set covers a Flask API with TODO comments, a Node.js CLI with stubbed flags and a FIXME, and a React app with an abandoned half-finished feature in git history
