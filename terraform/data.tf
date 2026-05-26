data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_platform.cluster_name
}

data "aws_secretsmanager_secret_version" "keycloak_admin" {
  secret_id = module.idp_sso.keycloak_admin_secret_arn
}
