# Global Terraform Variables for Zero-Trust IDP
# Copy to environments/<env>.tfvars and customize per environment

project_name = "ztidp"
environment  = "dev"
aws_region   = "me-central-1"
domain_name  = "idp.example.com"

common_tags = {
  ManagedBy = "Terraform"
  Project   = "ztidp"
  Owner     = "platform-team"
}

enable_backstage     = true
enable_keycloak      = true
enable_istio         = true
enable_gatekeeper    = true
enable_tekton        = true
enable_kubecost      = true
enable_cert_manager  = true
enable_spire         = false
enable_falco         = false

vpc_cidr = "10.0.0.0/16"
az_count = 3

cluster_version     = "1.29"
backstage_image_tag = "1.22.0"
backstage_replicas  = 2

keycloak_realm_name = "platform-engineering"

budget_threshold_usd = 500
enable_cloudfront_techdocs = false

teams = [
  {
    name        = "team-backend"
    cost_center = "CC-BACKEND-001"
    owners      = ["backend-lead@example.com"]
  },
  {
    name        = "team-frontend"
    cost_center = "CC-FRONTEND-002"
    owners      = ["frontend-lead@example.com"]
  },
  {
    name        = "team-data"
    cost_center = "CC-DATA-003"
    owners      = ["data-lead@example.com"]
  },
  {
    name        = "team-sre"
    cost_center = "CC-SRE-004"
    owners      = ["sre-lead@example.com"]
  }
]
