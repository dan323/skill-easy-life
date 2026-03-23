# JavaScript Reference

## Module systems

| System   | Syntax                       | File ext                                                |
|----------|------------------------------|---------------------------------------------------------|
| ESM      | `import`/`export`            | `.mjs`, or `.js` with `"type":"module"` in package.json |
| CommonJS | `require()`/`module.exports` | `.cjs`, or `.js` without `"type":"module"`              |

Tooling (Jest, ts-jest, some build plugins) often requires CommonJS even when the app uses ESM — configure them separately rather than switching the whole project.
