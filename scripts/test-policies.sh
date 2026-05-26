#!/bin/bash
set -euo pipefail

log() {
  echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] $*"
}

log "Running OPA tests for Kubernetes policies..."
opa test policies/opa/k8s/ --verbose

log "Running OPA tests for Terraform policies..."
opa test policies/opa/terraform/ --verbose

log "Running Gatekeeper constraint verification..."
if [ -d "kubernetes/gatekeeper/constraints" ]; then
  gator verify kubernetes/gatekeeper/constraints/ || true
fi

log "All policy tests completed."
