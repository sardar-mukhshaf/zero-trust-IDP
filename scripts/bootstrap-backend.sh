#!/bin/bash
set -euo pipefail

PROJECT_NAME="${PROJECT_NAME}"
AWS_REGION="${AWS_REGION}"
BUCKET_NAME="${PROJECT_NAME}-terraform-state"
DYNAMO_TABLE="${PROJECT_NAME}-terraform-locks"

log() {
  echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] $*"
}

log "Bootstrapping Terraform backend for ${PROJECT_NAME}..."

# Create S3 bucket
if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
  log "S3 bucket ${BUCKET_NAME} already exists."
else
  log "Creating S3 bucket ${BUCKET_NAME}..."
  if [ "${AWS_REGION}" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "${BUCKET_NAME}"
  else
    aws s3api create-bucket \
      --bucket "${BUCKET_NAME}" \
      --create-bucket-configuration LocationConstraint="${AWS_REGION}"
  fi
  aws s3api put-bucket-versioning \
    --bucket "${BUCKET_NAME}" \
    --versioning-configuration Status=Enabled
  aws s3api put-bucket-encryption \
    --bucket "${BUCKET_NAME}" \
    --server-side-encryption-configuration '{
      "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "aws:kms"}}]
    }'
  aws s3api put-public-access-block \
    --bucket "${BUCKET_NAME}" \
    --public-access-block-configuration \
      BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
fi

# Create DynamoDB table
if aws dynamodb describe-table --table-name "${DYNAMO_TABLE}" >/dev/null 2>&1; then
  log "DynamoDB table ${DYNAMO_TABLE} already exists."
else
  log "Creating DynamoDB table ${DYNAMO_TABLE}..."
  aws dynamodb create-table \
    --table-name "${DYNAMO_TABLE}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST
fi

log "Bootstrap complete."
