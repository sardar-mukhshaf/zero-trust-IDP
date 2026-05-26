output "keycloak_url" {
  description = "Keycloak URL"
  value       = "https://${var.sso_domain}"
  sensitive   = true
}

output "keycloak_realm_name" {
  description = "Keycloak realm name"
  value       = keycloak_realm.platform.realm
}

output "keycloak_admin_secret_arn" {
  description = "Keycloak admin secret ARN"
  value       = var.keycloak_admin_password_secret_arn
}
