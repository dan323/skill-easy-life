# Java Reference

## Updating dependencies

Dependencies live in `pom.xml` (Maven) or `build.gradle.kts` (Gradle).
See `maven.md` and `gradle.md` for update commands.

When upgrading:
1. Check release notes for breaking changes.
2. Update the version, run `mvn clean verify` or `./gradlew clean build`.
3. Resolve any transitive conflicts before committing.

## Traps worth remembering

- **`equals`/`hashCode`**: always override both together; use `Objects.equals` and `Objects.hash`. Records get these for free.
- **String comparison**: always `.equals()`, never `==`.
- **`List.of()` / `Set.of()` / `Map.of()`**: immutable — throw `UnsupportedOperationException` on mutation. Wrap in `new ArrayList<>(...)` for a mutable copy.
- **Checked exceptions**: must be declared or caught. Prefer unchecked (`RuntimeException`) for programming errors; checked for recoverable I/O or external failures.
