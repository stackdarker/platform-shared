#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "==> Finding OpenAPI specs..."
mapfile -t SPECS < <(find openapi -type f \( -name "openapi.yaml" -o -name "openapi.yml" \) | sort)

if [ ${#SPECS[@]} -eq 0 ]; then
  echo "No OpenAPI specs found under ./openapi"
  exit 1
fi

printf "Found %s spec(s):\n" "${#SPECS[@]}"
printf " - %s\n" "${SPECS[@]}"

run_redocly() {
  local spec="$1"
  echo "==> Redocly lint: $spec"
  npx -y @redocly/cli@latest lint --config .redocly.yaml "$spec"
}

run_spectral() {
  local spec="$1"
  echo "==> Spectral lint: $spec"
  npx -y @stoplight/spectral-cli@latest lint -r tooling/spectral/.spectral.yaml "$spec"
}

# Prefer npx, fallback to docker if npx isn't available
if command -v npx >/dev/null 2>&1; then
  echo "==> Using npx tooling (Redocly + Spectral)"
  for spec in "${SPECS[@]}"; do
    run_redocly "$spec"
    run_spectral "$spec"
  done
elif command -v docker >/dev/null 2>&1; then
  echo "==> npx not found. Using docker fallback for Redocly lint."
  for spec in "${SPECS[@]}"; do
    echo "==> Redocly lint (docker): $spec"
    docker run --rm -v "$ROOT_DIR:/work" -w /work redocly/openapi-cli:latest lint "$spec"
  done
  echo "WARNING: Spectral lint skipped (npx not found). Install Node.js or run Spectral locally."
else
  echo "ERROR: Neither npx nor docker is available. Install Node.js (recommended) or Docker."
  exit 1
fi

echo "✅ Validation passed for all OpenAPI specs."
