#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:?version required}"
OUT_DIR="${2:-dist}"

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR/catalog"

cp -R categories "$OUT_DIR/catalog/"
cp -R images "$OUT_DIR/catalog/"
cp -R modding-profiles "$OUT_DIR/catalog/"
cp -R mod-catalogs "$OUT_DIR/catalog/"
cp -R schemas "$OUT_DIR/catalog/"

cat > "$OUT_DIR/catalog/release-metadata.json" <<JSON
{
  "catalog_version": "${VERSION}",
  "generated_at_utc": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "git_commit": "${GITHUB_SHA:-local}",
  "source_repo": "${GITHUB_REPOSITORY:-local}"
}
JSON

(
  cd "$OUT_DIR/catalog"
  find . -type f -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
)

tar -C "$OUT_DIR" -czf "$OUT_DIR/catalog-${VERSION}.tar.gz" catalog
sha256sum "$OUT_DIR/catalog-${VERSION}.tar.gz" > "$OUT_DIR/catalog-${VERSION}.tar.gz.sha256"

echo "artifact_path=$OUT_DIR/catalog-${VERSION}.tar.gz" >> "${GITHUB_OUTPUT:-/dev/null}"
