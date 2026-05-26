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

variable "vpc_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "enable_spire" {
  type    = bool
  default = false
}

variable "enable_falco" {
  type    = bool
  default = false
}

variable "common_tags" {
  type = map(string)
}
