terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "~> 4.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(var.common_tags, {
      Environment = var.environment
      Project     = var.project_name
    })
  }
}

provider "kubernetes" {
  host                   = module.eks_platform.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_platform.cluster_ca_cert)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_platform.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_platform.cluster_ca_cert)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "keycloak" {
  client_id = "admin-cli"
  username  = "admin"
  password  = data.aws_secretsmanager_secret_version.keycloak_admin.secret_string
  url       = "https://sso.${var.domain_name}"
}
