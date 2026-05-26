variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "gatekeeper_version" {
  type = string
}

variable "enable_referential_policies" {
  type    = bool
  default = true
}

variable "opa_log_level" {
  type    = string
  default = "info"
}

variable "common_tags" {
  type = map(string)
}
