locals {
  name = "${var.service_name}-${var.environment}"
}

resource "aws_db_instance" "this" {
  identifier            = local.name
  engine                = var.db_engine
  engine_version        = var.db_engine == "postgres" ? "15.4" : "8.0"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true
  db_name               = replace(var.service_name, "-", "_")
  username              = "dbadmin"
  password              = random_password.this.result
  publicly_accessible   = false
  deletion_protection   = true
  skip_final_snapshot   = false
  final_snapshot_identifier = "${local.name}-final"

  tags = merge(var.common_tags, {
    Name        = local.name
    Environment = var.environment
    Team        = var.team_name
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "random_password" "this" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "this" {
  name                    = "${local.name}-db-credentials"
  description             = "RDS credentials for ${var.service_name}"
  recovery_window_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${local.name}-db-credentials"
  })
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = aws_db_instance.this.db_name
    username = aws_db_instance.this.username
    password = random_password.this.result
  })
}
