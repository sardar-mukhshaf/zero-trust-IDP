variable "service_name" {
  type = string
}

variable "team_name" {
  type = string
}

variable "cost_center" {
  type = string
}

variable "environment" {
  type = string
}

variable "namespace_resource_quota" {
  type = map(string)
}

variable "cluster_oidc" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
