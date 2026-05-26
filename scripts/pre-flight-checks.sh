#!/bin/bash
set -euo pipefail

log() {
  echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] $*"
}

fail=0

check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    log "✓ $1 found: $($1 --version 2>&1 | head -n1)"
  else
    log "✗ $1 not found"
    fail=1
  fi
}

check_aws() {
  log "Checking AWS credentials..."
  if aws sts get-caller-identity >/dev/null 2>&1; then
    ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    log "✓ AWS authenticated (Account: ${ACCOUNT})"
  else
    log "✗ AWS credentials not configured or invalid"
    fail=1
  fi
}

check_quotas() {
  log "Checking service quotas..."
  # EKS clusters per region (default 100)
  log "  (Manual) Verify EKS cluster quota in AWS Service Quotas console"
  # NAT gateways per AZ (default 5)
  log "  (Manual) Verify NAT gateway quota"
  # VPCs per region (default 5)
  log "  (Manual) Verify VPC quota"
}

log "Running pre-flight checks..."

check_command terraform
check_command kubectl
check_command helm
check_command tkn
check_command opa
check_command conftest
check_command gator
check_aws
check_quotas

if [ $fail -eq 0 ]; then
  log "All pre-flight checks passed."
else
  log "Some pre-flight checks failed. Please install missing tools or configure credentials."
  exit 1
fi
