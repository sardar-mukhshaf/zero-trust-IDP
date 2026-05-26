locals {
  name = "${var.project_name}-${var.environment}"
}

resource "aws_db_subnet_group" "backstage" {
  name       = "${local.name}-backstage-db"
  subnet_ids = var.private_subnets

  tags = merge(var.common_tags, {
    Name = "${local.name}-backstage-db"
  })
}

resource "aws_security_group" "backstage_db" {
  name        = "${local.name}-backstage-db-sg"
  description = "Backstage RDS security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from EKS"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  tags = merge(var.common_tags, {
    Name = "${local.name}-backstage-db-sg"
  })
}

resource "aws_db_instance" "backstage" {
  identifier             = "${local.name}-backstage"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = var.db_instance_class
  allocated_storage      = 50
  max_allocated_storage  = 200
  storage_encrypted      = true
  db_name                = "backstage"
  username               = "backstage"
  password               = random_password.backstage_db.result
  db_subnet_group_name   = aws_db_subnet_group.backstage.name
  vpc_security_group_ids = [aws_security_group.backstage_db.id]
  multi_az               = true
  publicly_accessible    = false
  deletion_protection    = true
  skip_final_snapshot    = false
  final_snapshot_identifier = "${local.name}-backstage-final"

  tags = merge(var.common_tags, {
    Name = "${local.name}-backstage"
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "random_password" "backstage_db" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "backstage_db" {
  name                    = "${local.name}-backstage-db"
  description             = "Backstage PostgreSQL credentials"
  recovery_window_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${local.name}-backstage-db"
  })
}

resource "aws_secretsmanager_secret_version" "backstage_db" {
  secret_id = aws_secretsmanager_secret.backstage_db.id
  secret_string = jsonencode({
    host     = aws_db_instance.backstage.address
    port     = aws_db_instance.backstage.port
    dbname   = aws_db_instance.backstage.db_name
    username = aws_db_instance.backstage.username
    password = random_password.backstage_db.result
  })
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
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }
}

resource "aws_iam_role" "backstage_irsa" {
  name = "${local.name}-backstage-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = var.cluster_oidc
      }
      Condition = {
        StringEquals = {
          "${replace(var.cluster_oidc, "arn:aws:iam::[0-9]*:oidc-provider/", "")}:sub" = "system:serviceaccount:backstage:backstage"
        }
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${local.name}-backstage-irsa"
  })
}

resource "aws_iam_role_policy" "backstage_techdocs" {
  name = "${local.name}-backstage-techdocs"
  role = aws_iam_role.backstage_irsa.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.techdocs.arn,
        "${aws_s3_bucket.techdocs.arn}/*"
      ]
    }]
  })
}

resource "kubernetes_namespace" "backstage" {
  metadata {
    name = "backstage"
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "kubernetes_config_map" "backstage_config" {
  metadata {
    name      = "backstage-config"
    namespace = kubernetes_namespace.backstage.metadata[0].name
  }

  data = {
    "app-config.production.yaml" = templatefile("${path.module}/app-config.yaml.tpl", {
      db_host       = aws_db_instance.backstage.address
      db_port       = aws_db_instance.backstage.port
      db_name       = aws_db_instance.backstage.db_name
      db_user       = aws_db_instance.backstage.username
      db_password   = random_password.backstage_db.result
      techdocs_bucket = aws_s3_bucket.techdocs.id
      aws_region    = data.aws_region.current.name
      keycloak_url  = var.keycloak_url
      realm_name    = var.keycloak_realm_name
      base_url      = "https://portal.${var.domain_name}"
    })
  }
}

data "aws_region" "current" {}
