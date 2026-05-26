locals {
  name = "${var.project_name}-${var.environment}"
}

resource "aws_kms_key" "platform" {
  description             = "KMS key for platform secrets"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(var.common_tags, {
    Name = "${local.name}-platform-kms"
  })
}

resource "aws_kms_alias" "platform" {
  name          = "alias/${local.name}-platform"
  target_key_id = aws_kms_key.platform.key_id
}

resource "aws_secretsmanager_secret" "keycloak_admin" {
  name                    = "${local.name}-keycloak-admin"
  description             = "Keycloak admin password"
  kms_key_id              = aws_kms_key.platform.arn
  recovery_window_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${local.name}-keycloak-admin"
  })
}

resource "aws_secretsmanager_secret_version" "keycloak_admin" {
  secret_id     = aws_secretsmanager_secret.keycloak_admin.id
  secret_string = random_password.keycloak_admin.result
}

resource "random_password" "keycloak_admin" {
  length  = 32
  special = true
}

resource "aws_secretsmanager_secret" "webhook" {
  name                    = "${local.name}-tekton-webhook"
  description             = "Tekton webhook secret"
  kms_key_id              = aws_kms_key.platform.arn
  recovery_window_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${local.name}-tekton-webhook"
  })
}

resource "aws_secretsmanager_secret_version" "webhook" {
  secret_id     = aws_secretsmanager_secret.webhook.id
  secret_string = random_password.webhook.result
}

resource "random_password" "webhook" {
  length  = 32
  special = false
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = "1.14.0"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.irsa_cert_manager.arn
  }

  depends_on = [aws_iam_role.irsa_cert_manager]
}

resource "aws_iam_role" "irsa_cert_manager" {
  name = "${local.name}-irsa-cert-manager"

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
          "${replace(var.cluster_oidc, "arn:aws:iam::[0-9]*:oidc-provider/", "")}:sub" = "system:serviceaccount:cert-manager:cert-manager"
        }
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${local.name}-irsa-cert-manager"
  })
}

resource "aws_iam_role_policy" "cert_manager" {
  name = "${local.name}-cert-manager-dns"
  role = aws_iam_role.irsa_cert_manager.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "route53:GetChange",
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets",
        "route53:ListHostedZonesByName"
      ]
      Resource = "*"
    }]
  })
}

resource "helm_release" "secrets_store_csi" {
  name       = "secrets-store-csi-driver"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  namespace  = "secrets-manager-csi"
  version    = "1.4.0"
  create_namespace = true

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }

  set {
    name  = "enableSecretRotation"
    value = "true"
  }
}

resource "kubernetes_manifest" "cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging"
    }
    spec = {
      acme = {
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email  = "platform@${var.domain_name}"
        privateKeySecretRef = {
          name = "letsencrypt-staging"
        }
        solvers = [{
          dns01 = {
            route53 = {
              region = data.aws_region.current.name
            }
          }
        }]
      }
    }
  }

  depends_on = [helm_release.cert_manager]
}

data "aws_region" "current" {}
