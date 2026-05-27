#!/bin/bash
set -euo pipefail

PROJECT_NAME="${PROJECT_NAME}"
ENVIRONMENT="${ENV}"
AWS_REGION="${AWS_REGION}"
ECR_REPO="${PROJECT_NAME}-${ENVIRONMENT}-backstage"
IMAGE_TAG="${TF_VAR_backstage_image_tag}"

cd backstage

log() {
  echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] $*"
}

log "Building Backstage image..."

# Login to ECR
aws ecr get-login-password --region "${AWS_REGION}" | \
  docker login --username AWS --password-stdin "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com"

# Create ECR repo if not exists
aws ecr describe-repositories --repository-names "${ECR_REPO}" >/dev/null 2>&1 || \
  aws ecr create-repository --repository-name "${ECR_REPO}"

# Build and push
docker build -t "${ECR_REPO}:${IMAGE_TAG}" -f packages/backend/Dockerfile .
docker tag "${ECR_REPO}:${IMAGE_TAG}" "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
docker push "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"

log "Image pushed to ECR."
log "Apply Kubernetes manifests via Terraform to deploy Backstage."
