locals {
  name_prefix = "${var.project_name}-${var.environment}"
  azs         = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  common_tags = merge(var.common_tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  })
}

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  azs          = local.azs
  az_count     = var.az_count
  common_tags  = local.common_tags

  enable_vpc_endpoints = true
}

module "eks_platform" {
  source = "./modules/eks_platform"

  project_name = var.project_name
  environment  = var.environment
  cluster_version = var.cluster_version
  vpc_id       = module.networking.vpc_id
  private_subnets = module.networking.private_subnet_ids
  azs          = local.azs
  common_tags  = local.common_tags

  depends_on = [module.networking]
}

module "security_zero_trust" {
  source = "./modules/security_zero_trust"

  project_name    = var.project_name
  environment     = var.environment
  cluster_name    = module.eks_platform.cluster_name
  cluster_oidc    = module.eks_platform.oidc_provider_arn
  vpc_id          = module.networking.vpc_id
  domain_name     = var.domain_name
  enable_spire    = var.enable_spire
  enable_falco    = var.enable_falco
  common_tags     = local.common_tags

  depends_on = [module.eks_platform]
}

module "service_mesh" {
  source = "./modules/service_mesh"

  project_name         = var.project_name
  environment          = var.environment
  cluster_name         = module.eks_platform.cluster_name
  istio_version        = "1.20.0"
  mtls_mode            = "STRICT"
  enable_egress_gateway = true
  domain_name          = var.domain_name
  cert_manager_enabled = var.enable_cert_manager
  common_tags          = local.common_tags

  depends_on = [module.eks_platform, module.security_zero_trust]
}

module "policy_engine" {
  source = "./modules/policy_engine"

  project_name              = var.project_name
  environment               = var.environment
  cluster_name              = module.eks_platform.cluster_name
  gatekeeper_version        = "3.14.0"
  enable_referential_policies = true
  opa_log_level             = "info"
  common_tags               = local.common_tags

  depends_on = [module.eks_platform]
}

module "idp_sso" {
  source = "./modules/idp_sso"

  project_name                = var.project_name
  environment                 = var.environment
  keycloak_realm_name         = var.keycloak_realm_name
  keycloak_admin_password_secret_arn = module.security_zero_trust.keycloak_admin_secret_arn
  sso_domain                  = "sso.${var.domain_name}"
  identity_provider_type      = "ldap"
  cluster_oidc                = module.eks_platform.oidc_provider_arn
  common_tags                 = local.common_tags

  depends_on = [module.eks_platform, module.security_zero_trust]
}

module "backstage" {
  source = "./modules/backstage"

  project_name         = var.project_name
  environment          = var.environment
  cluster_name         = module.eks_platform.cluster_name
  cluster_oidc         = module.eks_platform.oidc_provider_arn
  vpc_id               = module.networking.vpc_id
  private_subnets      = module.networking.private_subnet_ids
  backstage_image_tag  = var.backstage_image_tag
  backstage_replicas   = var.backstage_replicas
  techdocs_bucket_name = "${var.project_name}-${var.environment}-techdocs"
  db_instance_class    = "db.t3.medium"
  domain_name          = var.domain_name
  keycloak_realm_name  = var.keycloak_realm_name
  keycloak_url         = module.idp_sso.keycloak_url
  common_tags          = local.common_tags

  depends_on = [module.eks_platform, module.idp_sso, module.service_mesh, module.networking]
}

module "cicd_platform" {
  source = "./modules/cicd_platform"

  project_name         = var.project_name
  environment          = var.environment
  cluster_name         = module.eks_platform.cluster_name
  cluster_oidc         = module.eks_platform.oidc_provider_arn
  tekton_version       = "v0.58.0"
  enable_triggers      = true
  webhook_secret_arn   = module.security_zero_trust.webhook_secret_arn
  enable_manual_approval = true
  domain_name          = var.domain_name
  common_tags          = local.common_tags

  depends_on = [module.eks_platform, module.service_mesh, module.security_zero_trust]
}

module "cost_management" {
  source = "./modules/cost_management"

  project_name         = var.project_name
  environment          = var.environment
  cluster_name         = module.eks_platform.cluster_name
  kubecost_version     = "2.0.0"
  aws_payer_account_id = data.aws_caller_identity.current.account_id
  budget_threshold_usd = var.budget_threshold_usd
  allocation_labels    = ["team", "cost-center", "environment"]
  common_tags          = local.common_tags

  depends_on = [module.eks_platform]
}

module "docs_storage" {
  source = "./modules/docs_storage"

  project_name         = var.project_name
  environment          = var.environment
  techdocs_bucket_name = "${var.project_name}-${var.environment}-techdocs"
  enable_cloudfront    = var.enable_cloudfront_techdocs
  retention_days       = 365
  common_tags          = local.common_tags

  depends_on = [module.eks_platform]
}

module "golden_path_factory" {
  source = "./modules/golden_path_factory"

  project_name = var.project_name
  environment  = var.environment
  cluster_name = module.eks_platform.cluster_name
  cluster_oidc = module.eks_platform.oidc_provider_arn
  vpc_id       = module.networking.vpc_id
  common_tags  = local.common_tags

  depends_on = [module.eks_platform, module.service_mesh, module.policy_engine]
}
