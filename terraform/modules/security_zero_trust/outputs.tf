output "kms_key_arn" {
  description = "Platform KMS key ARN"
  value       = aws_kms_key.platform.arn
}

output "keycloak_admin_secret_arn" {
  description = "Keycloak admin secret ARN"
  value       = aws_secretsmanager_secret.keycloak_admin.arn
}

output "webhook_secret_arn" {
  description = "Tekton webhook secret ARN"
  value       = aws_secretsmanager_secret.webhook.arn
}

output "cert_manager_cluster_issuer" {
  description = "Cert manager cluster issuer name"
  value       = kubernetes_manifest.cluster_issuer.manifest.metadata.name
}
