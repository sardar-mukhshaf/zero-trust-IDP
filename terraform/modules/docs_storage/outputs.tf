output "techdocs_bucket_arn" {
  description = "TechDocs S3 bucket ARN"
  value       = aws_s3_bucket.techdocs.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.techdocs[0].domain_name : null
}
