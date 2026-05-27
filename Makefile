# Zero-Trust Internal Developer Platform Makefile
# Usage: make <target>

# Load environment variables from .env file
ifneq (,$(wildcard ./.env))
    include .env
    export $(shell sed 's/=.*//' .env)
endif

.PHONY: help init plan apply destroy backstage-up test-policies onboard-team pre-flight bootstrap

TERRAFORM_DIR := terraform
BACKSTAGE_DIR := backstage

help: ## Show this help message
	@echo "Zero-Trust IDP Platform - Make Targets"
	@echo "======================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

pre-flight: ## Run pre-flight checks (tools, AWS creds, quotas)
	@echo "Running pre-flight checks..."
	bash scripts/pre-flight-checks.sh

bootstrap: ## Bootstrap Terraform S3 backend and DynamoDB locking
	@echo "Bootstrapping Terraform backend..."
	bash scripts/bootstrap-backend.sh

init: bootstrap ## Initialize Terraform
	@echo "Initializing Terraform for environment: $(ENV)..."
	cd $(TERRAFORM_DIR) && terraform init \
		-backend-config="bucket=$(PROJECT_NAME)-terraform-state" \
		-backend-config="key=environments/$(ENV)/terraform.tfstate" \
		-backend-config="region=$(AWS_REGION)" \
		-backend-config="dynamodb_table=$(PROJECT_NAME)-terraform-locks"

plan: init ## Run Terraform plan
	@echo "Planning infrastructure for environment: $(ENV)..."
	cd $(TERRAFORM_DIR) && terraform plan \
		-out="$(ENV).tfplan"

apply: plan ## Apply Terraform changes
	@echo "Applying infrastructure for environment: $(ENV)..."
	cd $(TERRAFORM_DIR) && terraform apply "$(ENV).tfplan"

destroy: init ## Destroy infrastructure (DANGER)
	@echo "WARNING: This will destroy all resources in $(ENV)!"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ]
	cd $(TERRAFORM_DIR) && terraform destroy

backstage-up: ## Build and deploy Backstage to ECR
	@echo "Building and deploying Backstage..."
	bash scripts/install-backstage.sh

register-templates: ## Register Backstage golden path templates
	@echo "Registering Backstage templates..."
	bash scripts/register-templates.sh

test-policies: ## Run OPA and Gatekeeper policy tests
	@echo "Running policy tests..."
	bash scripts/test-policies.sh

onboard-team: ## Onboard a new engineering team (usage: make onboard-team TEAM=team-gamma)
	@if [ -z "$(TEAM)" ]; then \
		echo "Error: TEAM variable is required."; \
		echo "Usage: make onboard-team TEAM=team-gamma"; \
		exit 1; \
	fi
	@echo "Onboarding team: $(TEAM)..."
	bash scripts/onboard-team.sh "$(TEAM)"

fmt: ## Format Terraform code
	@echo "Formatting Terraform..."
	cd $(TERRAFORM_DIR) && terraform fmt -recursive

validate: init ## Validate Terraform configuration
	@echo "Validating Terraform..."
	cd $(TERRAFORM_DIR) && terraform validate

lint: ## Run tflint on Terraform code
	@echo "Running tflint..."
	cd $(TERRAFORM_DIR) && tflint --recursive

all: pre-flight init plan apply backstage-up register-templates test-policies ## Full platform deployment
	@echo "Platform deployment complete for environment: $(ENV)!"
