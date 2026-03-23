# Maven Reference

If available use `./mvnw` instead of `mvn` — it ensures the project-pinned Maven version is used.

## Key commands

```bash
./mvnw clean verify                          # compile + all tests
./mvnw package -DskipTests                  # package without tests
./mvnw dependency:tree -Dverbose            # show full tree with conflicts
./mvnw versions:display-dependency-updates  # show outdated dependencies
./mvnw versions:display-plugin-updates      # show outdated plugins
./mvnw versions:use-latest-releases         # auto-update all to latest (check for breaking changes after)
./mvnw help:effective-pom                   # show fully resolved POM
```

## Updating dependencies

For Spring Boot projects, update the parent POM version first — it manages compatible versions for most dependencies:

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.4.3</version>
</parent>
```

Use `<dependencyManagement>` to force a specific transitive version:

```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>com.fasterxml.jackson.core</groupId>
      <artifactId>jackson-databind</artifactId>
      <version>2.18.3</version>
    </dependency>
  </dependencies>
</dependencyManagement>
```

## Gotchas

- **SNAPSHOT versions**: mutable — Maven re-downloads on each build. Pin to a release for reproducible builds.
- **Stale local cache**: mysterious failures after version changes. Clear with `./mvnw dependency:purge-local-repository`.
- **Plugin versions**: managed separately from dependency versions — `<pluginManagement>` is distinct from `<dependencyManagement>`.

## Multi-module

```bash
./mvnw clean install -pl module-a,module-b   # build specific modules
./mvnw clean install -am -pl module-b        # build module-b and its upstream dependencies
```
