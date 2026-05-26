environment = "prod"
aws_region  = "me-central-1"
domain_name = "idp.example.com"

vpc_cidr = "10.2.0.0/16"
az_count = 3

cluster_version     = "1.29"
backstage_replicas  = 3
backstage_image_tag = "1.22.0"

keycloak_realm_name = "platform-engineering"

budget_threshold_usd = 500
enable_cloudfront_techdocs = true

enable_spire = true
enable_falco = true
