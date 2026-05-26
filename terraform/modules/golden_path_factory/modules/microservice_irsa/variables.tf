variable "service_name" {
  type = string
}

variable "team_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_oidc" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
