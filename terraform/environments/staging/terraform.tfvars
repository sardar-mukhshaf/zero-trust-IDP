environment = "staging"
aws_region  = "me-central-1"
domain_name = "staging.idp.example.com"

vpc_cidr = "10.1.0.0/16"
az_count = 3

cluster_version     = "1.29"
backstage_replicas  = 3
backstage_image_tag = "1.22.0"

keycloak_realm_name = "platform-engineering"

budget_threshold_usd = 300
enable_cloudfront_techdocs = false

enable_spire = false
enable_falco = false
