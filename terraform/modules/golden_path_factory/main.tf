locals {
  name = "${var.project_name}-${var.environment}"
}

module "microservice_namespace" {
  source = "./modules/microservice_namespace"

  for_each = toset(["team-backend", "team-frontend", "team-data", "team-sre"])

  service_name             = each.value
  team_name                = each.value
  cost_center              = "CC-${upper(replace(each.value, "-", ""))}-001"
  environment              = var.environment
  namespace_resource_quota = var.namespace_resource_quota
  cluster_oidc             = var.cluster_oidc
  common_tags              = var.common_tags
}

module "microservice_rds" {
  source = "./modules/microservice_rds"

  for_each = toset(["team-backend", "team-data"])

  service_name    = each.value
  team_name       = each.value
  environment     = var.environment
  db_engine       = "postgres"
  vpc_id          = var.vpc_id
  cluster_oidc    = var.cluster_oidc
  common_tags     = var.common_tags
}

module "microservice_sqs" {
  source = "./modules/microservice_sqs"

  for_each = toset(["team-backend"])

  service_name = each.value
  team_name    = each.value
  environment  = var.environment
  queue_type   = "standard"
  common_tags  = var.common_tags
}

module "microservice_s3" {
  source = "./modules/microservice_s3"

  for_each = toset(["team-frontend", "team-data"])

  service_name = each.value
  team_name    = each.value
  environment  = var.environment
  common_tags  = var.common_tags
}

module "microservice_irsa" {
  source = "./modules/microservice_irsa"

  for_each = toset(["team-backend", "team-frontend", "team-data", "team-sre"])

  service_name = each.value
  team_name    = each.value
  environment  = var.environment
  cluster_oidc = var.cluster_oidc
  common_tags  = var.common_tags
}
