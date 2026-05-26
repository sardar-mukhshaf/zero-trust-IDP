variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cluster_oidc" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
