# Mod Catalog API Contract

This contract defines how backend exposes `mod-catalogs/` to frontend.

Machine-readable artifacts:

- OpenAPI: `docs/openapi/mod-catalog-api.openapi.yaml`
- JSON Schemas: `schemas/api/*.schema.json`

## Goals

- Keep this repo declarative only.
- Backend resolves provider APIs and install logic.
- Frontend consumes one normalized model regardless of provider.

## Terms

- `catalog`: one file in `mod-catalogs/<game>/*.json`
- `catalog_type`: provider type (`github-release`, `modrinth`, `steam-workshop`)
- `entry`: one installable mod/plugin item returned by backend for a catalog

## Backend Ingestion

Backend loads and validates:

- `categories/**/*.json`
- `images/**/*.json`
- `modding-profiles/**/*.json`
- `mod-catalogs/**/*.json`

Each loaded mod catalog becomes:

```json
{
  "id": "minecraft-mods-modrinth",
  "category_id": "minecraft",
  "display_name": "Minecraft Mods (Modrinth)",
  "catalog_type": "modrinth",
  "enabled": true,
  "install_target_path": "mods/",
  "source": {}
}
```

## Public API

### 1) List catalogs for a game

`GET /v1/catalogs/{categoryId}/mod-catalogs`

Response:

```json
{
  "category_id": "minecraft",
  "catalogs": [
    {
      "id": "minecraft-plugins-github",
      "display_name": "Minecraft Plugins (GitHub Releases)",
      "catalog_type": "github-release",
      "enabled": true,
      "install_target_path": "plugins/",
      "supports_search": true,
      "supports_featured": true
    }
  ]
}
```

### 2) List entries in one catalog

`GET /v1/mod-catalogs/{catalogId}/entries?query=&page=1&page_size=30&sort=featured`

Response:

```json
{
  "catalog_id": "minecraft-mods-modrinth",
  "page": 1,
  "page_size": 30,
  "total": 1250,
  "entries": [
    {
      "entry_id": "modrinth:AANobbMI",
      "catalog_type": "modrinth",
      "name": "Sodium",
      "summary": "Rendering optimization mod",
      "author": "jellysquid3",
      "icon_url": "https://cdn.modrinth.com/data/AANobbMI/icon.png",
      "latest_version": "mc1.20.4-0.5.8",
      "game_versions": ["1.20.4"],
      "loader_types": ["fabric"],
      "download_size_bytes": 7340032,
      "updated_at": "2026-05-01T18:22:14Z",
      "source_ref": {
        "provider": "modrinth",
        "project_id": "AANobbMI",
        "version_id": "YxvV1A2B"
      }
    }
  ]
}
```

### 3) Install an entry

`POST /v1/servers/{serverId}/mod-installs`

Request:

```json
{
  "catalog_id": "minecraft-mods-modrinth",
  "entry_id": "modrinth:AANobbMI",
  "version_id": "YxvV1A2B",
  "install_target_path": "mods/"
}
```

Response:

```json
{
  "install_id": "inst_01JTK5E4W7C2F5Y3M1M7AQ3CDR",
  "status": "queued"
}
```

### 4) Get install status

`GET /v1/mod-installs/{installId}`

Response:

```json
{
  "install_id": "inst_01JTK5E4W7C2F5Y3M1M7AQ3CDR",
  "status": "succeeded",
  "server_id": "srv_01JTK1Y3Y9DE4CB4RMQ6Y8W1P3",
  "catalog_id": "minecraft-mods-modrinth",
  "entry_id": "modrinth:AANobbMI",
  "resolved_file_name": "sodium-fabric-0.5.8.jar",
  "resolved_version": "mc1.20.4-0.5.8",
  "installed_to": "mods/sodium-fabric-0.5.8.jar",
  "started_at": "2026-05-04T07:00:01Z",
  "finished_at": "2026-05-04T07:00:05Z"
}
```

## Normalized Entry Rules

Backend must always return these fields per `entry`:

- `entry_id` (stable provider-prefixed id)
- `catalog_type`
- `name`
- `summary`
- `author` (string, `"unknown"` fallback allowed)
- `latest_version`
- `updated_at` (RFC3339 UTC)
- `source_ref` (provider-specific ids used to install)

Optional fields:

- `icon_url`
- `download_size_bytes`
- `game_versions`
- `loader_types`

## Provider Mapping

### github-release

- Discover from GitHub Releases API for `source.owner/source.repo`.
- `entry_id`: `github:<owner>/<repo>:<release_id_or_tag>`
- `source_ref`:
  - `provider: "github-release"`
  - `owner`, `repo`
  - `release_tag`
  - `asset_name`
  - `asset_download_url`

### modrinth

- Discover projects/versions via Modrinth API.
- `entry_id`: `modrinth:<project_id>`
- `source_ref`:
  - `provider: "modrinth"`
  - `project_id`
  - `version_id`
  - `file_url`

### steam-workshop

- Discover workshop items for `source.appid`.
- `entry_id`: `steam-workshop:<publishedfileid>`
- `source_ref`:
  - `provider: "steam-workshop"`
  - `appid`
  - `publishedfileid`

## Error Contract

Errors return:

```json
{
  "error": {
    "code": "CATALOG_PROVIDER_UNAVAILABLE",
    "message": "Modrinth API timed out",
    "retryable": true
  }
}
```

Recommended error codes:

- `CATALOG_NOT_FOUND`
- `ENTRY_NOT_FOUND`
- `UNSUPPORTED_CATALOG_TYPE`
- `CATALOG_PROVIDER_UNAVAILABLE`
- `INSTALL_FAILED`
- `VALIDATION_FAILED`

## Frontend Expectations

- Use only normalized fields for list/cards/tables.
- Use `catalog_type` for badge and filtering.
- Start installs through backend only.
- Poll install status endpoint until terminal state:
  - `succeeded`
  - `failed`
  - `canceled`
