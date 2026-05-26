locals {
  name = "${var.project_name}-${var.environment}"
}

resource "aws_s3_bucket" "techdocs" {
  bucket = var.techdocs_bucket_name

  tags = merge(var.common_tags, {
    Name = var.techdocs_bucket_name
  })
}

resource "aws_s3_bucket_versioning" "techdocs" {
  bucket = aws_s3_bucket.techdocs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "techdocs" {
  bucket = aws_s3_bucket.techdocs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "techdocs" {
  bucket = aws_s3_bucket.techdocs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "techdocs" {
  bucket = aws_s3_bucket.techdocs.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    transition {
      days          = var.retention_days
      storage_class = "GLACIER"
    }
  }
}

resource "aws_cloudfront_distribution" "techdocs" {
  count = var.enable_cloudfront ? 1 : 0

  enabled         = true
  is_ipv6_enabled = true
  comment         = "TechDocs CDN for ${local.name}"

  origin {
    domain_name = aws_s3_bucket.techdocs.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.techdocs.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.techdocs[0].cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.techdocs.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.common_tags, {
    Name = "${local.name}-techdocs-cdn"
  })
}

resource "aws_cloudfront_origin_access_identity" "techdocs" {
  count = var.enable_cloudfront ? 1 : 0

  comment = "TechDocs OAI for ${local.name}"
}
