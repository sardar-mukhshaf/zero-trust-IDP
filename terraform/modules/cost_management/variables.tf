variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "kubecost_version" {
  type = string
}

variable "aws_payer_account_id" {
  type = string
}

variable "budget_threshold_usd" {
  type = number
}

variable "allocation_labels" {
  type = list(string)
}

variable "common_tags" {
  type = map(string)
}
