output "db_endpoint" {
  value     = aws_db_instance.this.address
  sensitive = true
}

output "secret_arn" {
  value = aws_secretsmanager_secret.this.arn
}
