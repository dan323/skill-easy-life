# Gradle Reference

Always use `./gradlew` instead of `gradle` — it ensures the project-pinned Gradle version is used.
Commit `gradlew`, `gradlew.bat`, and `gradle/wrapper/` — never gitignore them.

## Key commands

```bash
./gradlew clean build                                        # full clean rebuild + tests
./gradlew check                                             # all verification (test, lint, etc.)
./gradlew dependencies --configuration runtimeClasspath     # dependency tree focused on runtime
./gradlew dependencyUpdates                                 # show outdated deps (needs ben-manes/versions plugin)
./gradlew tasks                                             # list available tasks
./gradlew wrapper --gradle-version 8.13                     # update the wrapper version
```

## Updating dependencies

Add the versions plugin to `build.gradle.kts` to detect outdated dependencies:

```kotlin
plugins {
    id("com.github.ben-manes.versions") version "0.51.0"
}
```

Then update versions in the `dependencies {}` block or in `gradle/libs.versions.toml`.

## Version catalog (`gradle/libs.versions.toml`)

Preferred way to centralise versions in multi-module projects:

```toml
[versions]
spring-boot = "3.4.3"

[libraries]
spring-boot-web = { module = "org.springframework.boot:spring-boot-starter-web", version.ref = "spring-boot" }

[plugins]
spring-boot = { id = "org.springframework.boot", version.ref = "spring-boot" }
```

## `implementation` vs `api`

| Configuration    | Exposed to consumers | Use when                              |
|------------------|----------------------|---------------------------------------|
| `implementation` | No                   | Default — internal dependency         |
| `api`            | Yes                  | Library modules that re-export a type |

Prefer `implementation` — `api` leaks transitive deps and forces recompilation of downstream modules on every change.

## Conflict resolution

```kotlin
// Force a version
configurations.all {
    resolutionStrategy { force("com.fasterxml.jackson.core:jackson-databind:2.18.3") }
}

// Or use a constraint (preferred)
dependencies {
    constraints {
        implementation("com.fasterxml.jackson.core:jackson-databind:2.18.3")
    }
}
```

## Gotchas

- **Stale build cache**: run `./gradlew clean build` or `--rerun-tasks` when results look wrong.
- **Configuration cache**: some plugins don't support it. Add `org.gradle.configuration-cache.problems=warn` to `gradle.properties` while waiting for a fix.
- **Daemon**: if builds behave strangely, kill all daemons with `./gradlew --stop` and retry.
- **JVM toolchain**: set `java { toolchain { languageVersion = JavaLanguageVersion.of(21) } }` to decouple the build JDK from the system JDK.

## Multi-module

```bash
./gradlew :module-name:build   # build a specific subproject
./gradlew :module-name:test    # test a specific subproject
```
