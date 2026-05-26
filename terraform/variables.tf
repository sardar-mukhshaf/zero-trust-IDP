variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "ztidp"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.project_name))
    error_message = "project_name must be lowercase alphanumeric with hyphens, 3-21 chars, starting with a letter."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "me-central-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS region identifier."
  }
}

variable "domain_name" {
  description = "Base domain for platform services"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "ztidp"
  }
}

variable "enable_backstage" {
  description = "Enable Backstage module"
  type        = bool
  default     = true
}

variable "enable_keycloak" {
  description = "Enable Keycloak SSO module"
  type        = bool
  default     = true
}

variable "enable_istio" {
  description = "Enable Istio service mesh module"
  type        = bool
  default     = true
}

variable "enable_gatekeeper" {
  description = "Enable OPA Gatekeeper policy engine"
  type        = bool
  default     = true
}

variable "enable_tekton" {
  description = "Enable Tekton CI/CD platform"
  type        = bool
  default     = true
}

variable "enable_kubecost" {
  description = "Enable Kubecost cost management"
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "Enable cert-manager"
  type        = bool
  default     = true
}

variable "enable_spire" {
  description = "Enable SPIFFE/SPIRE workload identity"
  type        = bool
  default     = false
}

variable "enable_falco" {
  description = "Enable Falco runtime security"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block for the platform VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "az_count" {
  description = "Number of availability zones"
  type        = number
  default     = 3

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3."
  }
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.29"

  validation {
    condition     = can(regex("^1\\.(2[7-9]|[3-9][0-9])$", var.cluster_version))
    error_message = "cluster_version must be 1.27 or higher."
  }
}

variable "backstage_image_tag" {
  description = "Backstage container image tag"
  type        = string
  default     = "1.22.0"
}

variable "backstage_replicas" {
  description = "Number of Backstage replicas"
  type        = number
  default     = 2
}

variable "keycloak_realm_name" {
  description = "Keycloak realm name for platform SSO"
  type        = string
  default     = "platform-engineering"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}$", var.keycloak_realm_name))
    error_message = "keycloak_realm_name must be lowercase alphanumeric with hyphens, 2-31 chars."
  }
}

variable "teams" {
  description = "List of engineering teams to onboard"
  type = list(object({
    name        = string
    cost_center = string
    owners      = list(string)
  }))
  default = []
}

variable "budget_threshold_usd" {
  description = "Daily budget alert threshold in USD"
  type        = number
  default     = 500
}

variable "enable_cloudfront_techdocs" {
  description = "Enable CloudFront for TechDocs delivery"
  type        = bool
  default     = false
}
