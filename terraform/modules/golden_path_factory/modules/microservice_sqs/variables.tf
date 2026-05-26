variable "service_name" {
  type = string
}

variable "team_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "queue_type" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
