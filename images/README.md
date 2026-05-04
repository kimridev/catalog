# Game Image Definitions

This folder is the repo-owned source for Kimri-managed game image references.

Structure:

```text
catalog/images/<game>/<variant>.json
```

Each file should describe one supported runtime image for a specific variant.

Recommended fields:

```json
{
  "id": "minecraft-vanilla",
  "category_id": "minecraft",
  "display_name": "Minecraft Vanilla",
  "slot_requirement": 1,
  "support_level": "advanced",
  "image": {
    "repository": "ghcr.io/kimri/minecraft",
    "tag": "1.20.4",
    "tag_policy": "pinned"
  }
}
```

These files are intended to be the human-maintained source material that can be wrapped into admin catalog import snapshots later.

Additional curated fields are allowed and preserved as-is during catalog import. That is the intended place for manual data such as:

```json
{
  "logo_asset_path": "catalog/icons/minecraft.png",
  "frontend_special_handling": ["minecraft", "modpack-browser"],
  "default_join_ports": ["25565/tcp"],
  "known_config_files": ["server.properties", "eula.txt"],
  "primary_save_paths": ["world/"],
  "supported_versions": ["1.20.4", "1.20.6"]
}
```

The backend still validates the required runtime fields (`id`, `category_id`, `slot_requirement`, image policy, compatibility IDs), but it now keeps the rest of the curated JSON intact and returns it to clients under each item's `payload`.
