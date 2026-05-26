variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_oidc" {
  type = string
}

variable "tekton_version" {
  type = string
}

variable "enable_triggers" {
  type    = bool
  default = true
}

variable "webhook_secret_arn" {
  type = string
}

variable "enable_manual_approval" {
  type    = bool
  default = true
}

variable "domain_name" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
