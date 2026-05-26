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

variable "common_tags" {
  type = map(string)
}

variable "namespace_resource_quota" {
  type = map(string)
  default = {
    "pods"             = "50"
    "requests.cpu"     = "20"
    "requests.memory"  = "64Gi"
    "limits.cpu"       = "40"
    "limits.memory"    = "128Gi"
  }
}
