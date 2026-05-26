output "backstage_db_endpoint" {
  description = "Backstage RDS endpoint"
  value       = aws_db_instance.backstage.address
  sensitive   = true
}

output "techdocs_bucket_name" {
  description = "TechDocs S3 bucket name"
  value       = aws_s3_bucket.techdocs.id
}

output "backstage_irsa_role_arn" {
  description = "Backstage IRSA role ARN"
  value       = aws_iam_role.backstage_irsa.arn
}
