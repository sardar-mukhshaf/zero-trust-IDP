variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "keycloak_realm_name" {
  type = string
}

variable "keycloak_admin_password_secret_arn" {
  type = string
}

variable "sso_domain" {
  type = string
}

variable "identity_provider_type" {
  type = string
}

variable "cluster_oidc" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
