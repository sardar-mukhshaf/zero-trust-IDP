locals {
  name = "${var.project_name}-${var.environment}"
}

resource "helm_release" "keycloak" {
  name       = "keycloak"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "keycloak"
  namespace  = "keycloak"
  version    = "18.0.0"
  create_namespace = true

  set {
    name  = "auth.adminPassword"
    value = data.aws_secretsmanager_secret_version.keycloak_admin.secret_string
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "ingress.enabled"
    value = "false"
  }

  set {
    name  = "postgresql.enabled"
    value = "true"
  }

  set {
    name  = "postgresql.auth.password"
    value = random_password.keycloak_db.result
  }

  set {
    name  = "podLabels.istio-injection"
    value = "enabled"
  }
}

resource "random_password" "keycloak_db" {
  length  = 32
  special = false
}

data "aws_secretsmanager_secret_version" "keycloak_admin" {
  secret_id = var.keycloak_admin_password_secret_arn
}

resource "keycloak_realm" "platform" {
  realm   = var.keycloak_realm_name
  enabled = true

  display_name = "Platform Engineering"
}

resource "keycloak_openid_client" "backstage" {
  realm_id  = keycloak_realm.platform.id
  client_id = "backstage"

  name    = "Backstage Portal"
  enabled = true

  access_type = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://portal.${var.sso_domain}/api/auth/oidc/handler/frame",
    "https://portal.${var.sso_domain}/*"
  ]

  standard_flow_enabled = true
  direct_access_grants_enabled = false
}

resource "keycloak_group" "platform_admins" {
  realm_id = keycloak_realm.platform.id
  name     = "platform-admins"
}

resource "keycloak_group" "team_backend" {
  realm_id = keycloak_realm.platform.id
  name     = "team-backend"
}

resource "keycloak_group" "team_frontend" {
  realm_id = keycloak_realm.platform.id
  name     = "team-frontend"
}

resource "keycloak_group" "team_data" {
  realm_id = keycloak_realm.platform.id
  name     = "team-data"
}

resource "keycloak_group" "team_sre" {
  realm_id = keycloak_realm.platform.id
  name     = "team-sre"
}

resource "keycloak_role" "scaffolder_user" {
  realm_id = keycloak_realm.platform.id
  name     = "scaffolder-user"
}

resource "keycloak_role" "terraform_applier" {
  realm_id = keycloak_realm.platform.id
  name     = "terraform-applier"
}

resource "keycloak_role" "cluster_reader" {
  realm_id = keycloak_realm.platform.id
  name     = "cluster-reader"
}
