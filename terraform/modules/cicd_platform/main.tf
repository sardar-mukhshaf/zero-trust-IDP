locals {
  name = "${var.project_name}-${var.environment}"
}

resource "helm_release" "tekton_pipelines" {
  name       = "tekton-pipelines"
  repository = "https://tekton-charts.storage.googleapis.com"
  chart      = "tekton-pipeline"
  namespace  = "tekton-pipelines"
  version    = var.tekton_version
  create_namespace = true
}

resource "helm_release" "tekton_triggers" {
  count = var.enable_triggers ? 1 : 0

  name       = "tekton-triggers"
  repository = "https://tekton-charts.storage.googleapis.com"
  chart      = "tekton-trigger"
  namespace  = "tekton-pipelines"
  version    = "0.26.0"
}

resource "aws_iam_role" "tekton_irsa" {
  name = "${local.name}-tekton-irsa"

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
          "${replace(var.cluster_oidc, "arn:aws:iam::[0-9]*:oidc-provider/", "")}:sub" = "system:serviceaccount:tekton-pipelines:tekton-pipelines-controller"
        }
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${local.name}-tekton-irsa"
  })
}

resource "aws_iam_role_policy" "tekton_ecr" {
  name = "${local.name}-tekton-ecr"
  role = aws_iam_role.tekton_irsa.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy" "tekton_s3" {
  name = "${local.name}-tekton-s3"
  role = aws_iam_role.tekton_irsa.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy" "tekton_dynamodb" {
  name = "${local.name}-tekton-dynamodb"
  role = aws_iam_role.tekton_irsa.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ]
      Resource = "*"
    }]
  })
}

resource "kubernetes_namespace" "tekton_pipelines" {
  metadata {
    name = "tekton-pipelines"
    labels = {
      istio-injection = "enabled"
    }
  }
}
