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

variable "private_subnets" {
  type = list(string)
}

variable "backstage_image_tag" {
  type = string
}

variable "backstage_replicas" {
  type = number
}

variable "techdocs_bucket_name" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "keycloak_realm_name" {
  type = string
}

variable "keycloak_url" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
