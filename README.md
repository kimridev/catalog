# catalog

Public source-of-truth catalog for Kimri game metadata.

## What this repo contains

- `categories/`: game category definitions
- `images/`: variant/runtime image definitions (historical folder name)
- `modding-profiles/`: modding profile definitions and compatibility
- `mod-catalogs/`: mod/plugin catalog providers and install targets
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


## Production Rollout

- Repo split + versioning/import policy:
  - `docs/prod-catalog-rollout.md`
- Release artifact workflow:
  - `.github/workflows/release-catalog.yml`

## Contracts

- Mod/plugin catalog backend/frontend contract:
  - `docs/mod-catalog-api-contract.md`
- OpenAPI:
  - `docs/openapi/mod-catalog-api.openapi.yaml`
- API payload schemas + examples:
  - `schemas/api/*.schema.json`
  - `examples/api/*.json`

## Automated Docker publish dispatch

This repo includes `.github/workflows/docker-publish-dispatch.yml`.

On push to `main` (when `images/**/*.json` changes), it:
- auto-discovers all `image.repository` + `image.tag` entries
- maps `ghcr.io/<owner>/<name>` to GitHub repo `<owner>/<name>`
- dispatches `repository_dispatch` event `catalog-image-publish` to each target repo

### Required secret

Set repository secret:
- `CATALOG_DISPATCH_TOKEN`: PAT with permission to call `repository_dispatch` on target image repos.

### Target repo requirement

Each image repo should have a workflow listening to:
- `on: repository_dispatch` with `types: [catalog-image-publish]`

Then build/push its Docker image (typically tag with `latest` and/or SHA).
