variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "common_tags" {
  type = map(string)
}

variable "node_instance_types" {
  type    = list(string)
  default = ["m6i.large", "m6i.xlarge"]
}

variable "enable_fargate_profiles" {
  type    = bool
  default = false
}

variable "cluster_endpoint_private_access" {
  type    = bool
  default = true
}
