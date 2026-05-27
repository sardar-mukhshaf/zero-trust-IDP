#!/bin/bash
set -euo pipefail

TEAM="${1:-}"
if [ -z "${TEAM}" ]; then
  echo "Usage: $0 <team-name>"
  echo "Example: $0 team-gamma"
  exit 1
fi

PROJECT_NAME="${PROJECT_NAME}"
ENVIRONMENT="${ENV}"
AWS_REGION="${AWS_REGION}"

cd terraform

log() {
  echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] $*"
}

log "Onboarding team: ${TEAM}..."

# Create Keycloak group (via Terraform or API)
# This is a placeholder - in production, use Terraform or Keycloak API
log "Creating Keycloak group ${TEAM}..."

# Create namespace via Terraform
cat > "environments/${ENVIRONMENT}/${TEAM}.tfvars" <<EOF
teams = [
  {
    name        = "${TEAM}"
    cost_center = "CC-${TEAM^^}-NEW"
    owners      = ["${TEAM}-lead@example.com"]
  }
]
EOF

log "Team ${TEAM} onboarded."
log "Next steps:"
log "  1. Review ${TEAM}.tfvars"
log "  2. Run: make plan ENV=${ENVIRONMENT}"
log "  3. Run: make apply ENV=${ENVIRONMENT}"
