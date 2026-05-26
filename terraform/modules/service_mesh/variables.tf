variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "istio_version" {
  type = string
}

variable "mtls_mode" {
  type = string

  validation {
    condition     = var.mtls_mode == "STRICT"
    error_message = "mtls_mode must be STRICT for zero-trust."
  }
}

variable "enable_egress_gateway" {
  type    = bool
  default = true
}

variable "domain_name" {
  type = string
}

variable "cert_manager_enabled" {
  type    = bool
  default = true
}

variable "common_tags" {
  type = map(string)
}
