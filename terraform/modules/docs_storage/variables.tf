variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "techdocs_bucket_name" {
  type = string
}

variable "enable_cloudfront" {
  type    = bool
  default = false
}

variable "retention_days" {
  type    = number
  default = 365
}

variable "common_tags" {
  type = map(string)
}
