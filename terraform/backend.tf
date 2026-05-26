terraform {
  required_version = ">= 1.7.0"

  backend "s3" {
    bucket         = "ztidp-terraform-state"
    key            = "platform/terraform.tfstate"
    region         = "me-central-1"
    encrypt        = true
    dynamodb_table = "ztidp-terraform-locks"
  }
}
