# TypeScript Reference

## Config files

| File                  | Purpose                                                        |
|-----------------------|----------------------------------------------------------------|
| `tsconfig.json`       | Main compiler config (used by Vite/bundler)                    |
| `tsconfig.jest.json`  | Separate config for Jest — must override module to commonjs    |
| `tsconfig.build.json` | Optional production build config (excludes tests)              |

## Jest compatibility — always use a split tsconfig

`module: ESNext` + `moduleResolution: bundler` in `tsconfig.json` breaks `ts-jest`.
Always add a separate `tsconfig.jest.json`:

```json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "module": "commonjs",
    "moduleResolution": "node",
    "types": ["jest", "node", "@testing-library/jest-dom"]
  }
}
```

Wire it in `jest.config.ts`:
```ts
transform: { '^.+\\.tsx?$': ['ts-jest', { tsconfig: 'tsconfig.jest.json' }] }
```

## `tsconfig` pitfalls

- **`types` field**: when set, it restricts which `@types/*` packages are auto-included. Explicitly list everything needed (`jest`, `node`, `vite/client`, etc.) — or omit the field entirely to include all installed `@types/*`.
- **`moduleResolution: bundler`**: only valid when a bundler handles transpilation. Never use it in `tsconfig.jest.json`.
- **`isolatedModules: true`**: every file must have at least one `import`/`export`. Required by Vite/esbuild.
- **`noEmit: true`**: TypeScript only type-checks; the bundler handles transpilation. Standard when using Vite.
