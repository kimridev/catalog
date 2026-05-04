# Production Catalog Rollout

## Repo split

Use two repos:

- `catalog-json`: JSON definitions, schemas, API contracts, validation workflows.
- `catalog-images`: Dockerfiles/build pipelines and GHCR publishing.

Do not mix runtime image builds with catalog JSON release lifecycle.

## Versioning

- Release immutable tags: `catalog-vYYYY.MM.DD.N`
- Every tag publishes:
  - `catalog-<version>.tar.gz`
  - `catalog-<version>.tar.gz.sha256`
  - `release-metadata.json`
  - `SHA256SUMS` for files inside the bundle

## Backend import contract

Backend should import only tagged artifacts, never raw `main` branch.

Required import checks:

1. Verify release checksum (`*.tar.gz.sha256`).
2. Verify internal `SHA256SUMS` after extract.
3. Validate JSON using schema set in artifact.
4. Dry-run validation/import before activation.
5. Activate only if import succeeds.
6. Keep previous catalog version for rollback.

## Rollback

- Catalog activation is pointer-based (`active_catalog_version`).
- Rollback is changing pointer to prior successful version.
- No mutation of old releases.

## Recommended deployment flow

1. PR JSON changes in `catalog-json`.
2. CI validation passes.
3. Merge and create catalog tag.
4. Release workflow emits immutable artifact.
5. Backend deploy job fetches artifact, verifies, imports, activates.
6. Smoke tests call catalog endpoints.

## Operational endpoints

Expose from backend:

- `GET /v1/catalog/version` (active version and commit)
- `POST /v1/admin/catalog/import` (dry-run + apply)
- `POST /v1/admin/catalog/activate` (activate imported version)
