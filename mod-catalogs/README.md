# Mod/Plugin Catalogs

This folder defines how game-specific mod/plugin catalogs are sourced and installed.

Structure:

```text
catalog2/mod-catalogs/<game>/<catalog>.json
```

Supported `catalog_type` values:

- `github-release`: download release assets from GitHub repos.
- `modrinth`: use Modrinth project/version APIs.
- `steam-workshop`: use Steam Workshop APIs (for example with tModLoader/Terraria).
