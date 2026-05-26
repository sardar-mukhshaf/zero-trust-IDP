terraform {
  required_version = ">= 1.7.0"

  backend "s3" {
    bucket         = "ztidp-terraform-state"
    key            = "services/${{ values.service_name }}/terraform.tfstate"
    region         = "me-central-1"
    encrypt        = true
    dynamodb_table = "ztidp-terraform-locks"
  }
}

module "microservice" {
  source = "github.com/example-org/ztidp//terraform/modules/golden_path_factory/modules/microservice_namespace"

  service_name = "${{ values.service_name }}"
  team_name    = "${{ values.team_name }}"
  cost_center  = "CC-${upper(replace("${{ values.team_name }}", "-", ""))}-001"
  environment  = var.environment
  namespace_resource_quota = {
    pods             = "20"
    requests.cpu     = "10"
    requests.memory  = "32Gi"
    limits.cpu       = "20"
    limits.memory    = "64Gi"
  }
  cluster_oidc = var.cluster_oidc
  common_tags  = var.common_tags
}

%{ if values.db_type != "none" }
module "database" {
  source = "github.com/example-org/ztidp//terraform/modules/golden_path_factory/modules/microservice_rds"

  service_name = "${{ values.service_name }}"
  team_name    = "${{ values.team_name }}"
  environment  = var.environment
  db_engine    = "${{ values.db_type }}"
  vpc_id       = var.vpc_id
  cluster_oidc = var.cluster_oidc
  common_tags  = var.common_tags
}
%{ endif }

%{ if values.enable_s3 }
module "storage" {
  source = "github.com/example-org/ztidp//terraform/modules/golden_path_factory/modules/microservice_s3"

  service_name = "${{ values.service_name }}"
  team_name    = "${{ values.team_name }}"
  environment  = var.environment
  common_tags  = var.common_tags
}
%{ endif }

%{ if values.queue_type != "none" }
module "queue" {
  source = "github.com/example-org/ztidp//terraform/modules/golden_path_factory/modules/microservice_sqs"

  service_name = "${{ values.service_name }}"
  team_name    = "${{ values.team_name }}"
  environment  = var.environment
  queue_type   = "${{ values.queue_type }}"
  common_tags  = var.common_tags
}
%{ endif }
