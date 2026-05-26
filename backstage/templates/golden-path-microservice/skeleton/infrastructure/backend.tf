terraform {
  backend "s3" {
    bucket         = "ztidp-terraform-state"
    key            = "services/${{ values.service_name }}/terraform.tfstate"
    region         = "me-central-1"
    encrypt        = true
    dynamodb_table = "ztidp-terraform-locks"
  }
}
