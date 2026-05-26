#!/bin/bash
set -euo pipefail

BACKSTAGE_URL="${BACKSTAGE_URL:-https://portal.idp.example.com}"
TOKEN="${BACKSTAGE_TOKEN:-}"

cd backstage/templates

log() {
  echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] $*"
}

register_template() {
  local path="$1"
  log "Registering template: ${path}"
  curl -fsSL -X POST "${BACKSTAGE_URL}/api/scaffolder/v2/templates" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" \
    -d @"${path}" || log "Warning: Failed to register ${path}"
}

log "Registering Backstage golden path templates..."

register_template "golden-path-microservice/template.yaml"
register_template "golden-path-data-pipeline/template.yaml"
register_template "golden-path-frontend/template.yaml"

log "Template registration complete."
