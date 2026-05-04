# catalog

Public source-of-truth catalog for Kimri game metadata.

## What this repo contains

- `categories/`: game category definitions
- `images/`: variant/runtime image definitions (historical folder name)
- `modding-profiles/`: modding profile definitions and compatibility
- `data.txt`: manual curation checklist and guidance
- `schemas/catalog.schema.json`: JSON schema for definitions

## ID stability

IDs are product keys. Keep them stable once published.

Examples:
- category: `minecraft`, `terraria`
- variant: `minecraft-vanilla`, `terraria-tmodloader`
- profile: `minecraft-fabric`, `terraria-tmodloader`

## Validation

This repo validates all `*.json` files on PR/push via GitHub Actions.

## Usage downstream

Backend should ingest these JSON definitions and publish catalog versions.
Frontend should consume catalog via backend API and branch behavior by ID.
