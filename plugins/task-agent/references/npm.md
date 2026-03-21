# npm Reference

## Package files

| File                | Purpose                                  |
|---------------------|------------------------------------------|
| `package.json`      | Declares dependencies and version ranges |
| `package-lock.json` | Exact locked versions; must be committed |
| `.npmrc`            | Per-project npm config (registry, flags) |
| `node_modules/`     | Never committed                          |

## Updating dependencies

```bash
# Check what is outdated
npm outdated

# Update all packages within declared ranges (updates lock file only)
npm update

# Update package.json ranges to latest and reinstall
npx npm-check-updates -u && npm install

# Update a single package to latest
npm install <pkg>@latest
```

Always run a plain `npm install` after editing `package.json` to regenerate `package-lock.json`.
**Never use `--legacy-peer-deps`** to paper over conflicts — resolve them by choosing compatible versions instead.

## Peer dependency conflicts

When `npm install` reports peer conflicts:
1. Read the conflict message to identify which packages disagree.
2. Pin one of the conflicting packages to a version that satisfies all peers.
3. Re-run `npm install` without any flags.
4. Only use `--legacy-peer-deps` as a last resort, and document why in the commit message.

## Lock file integrity

```bash
npm ci          # clean install, strict — fails if lock file is out of sync (use in CI)
npm install     # install + update lock file (use locally)
```

`npm ci` is the best signal that a lock file is valid — if it fails, the lock file was generated incorrectly.

## Workspaces (monorepos)

```bash
npm install                                    # install all workspaces from root
npm run build --workspace=packages/foo         # run script in a specific workspace
npm install lodash --workspace=packages/foo    # add dep to a specific workspace
```

`package-lock.json` lives at the root and covers all workspaces.

## Scripts

```bash
npm run <script>   # run any script from package.json "scripts"
npm test           # shorthand for npm run test
npm start          # shorthand for npm run start
```

## Useful flags

| Flag                  | Effect                                 |
|-----------------------|----------------------------------------|
| `--save-dev` / `-D`   | Add to devDependencies                 |
| `--save-exact` / `-E` | Pin exact version (no `^` or `~`)      |
| `--dry-run`           | Show what would change without writing |

## Version ranges in package.json

| Syntax   | Meaning                             |
|----------|-------------------------------------|
| `^1.2.3` | Compatible with 1.x.x (most common) |
| `~1.2.3` | Patch updates only (1.2.x)          |
| `1.2.3`  | Exact version                       |

## Common gotchas

- **Lock file divergence**: editing `package.json` manually without running `npm install` leaves the lock file stale.
- **Node version mismatch**: check `engines` field in `package.json`; use `nvm use` to switch.
- **Phantom dependencies**: code importing packages not in `package.json` — works locally but breaks with `npm ci`.
- **Audit issues**: `npm audit` reports vulnerabilities; `npm audit fix` auto-fixes safe ones.
