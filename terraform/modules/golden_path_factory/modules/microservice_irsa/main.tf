locals {
  name = "${var.service_name}-${var.environment}"
}

resource "aws_iam_role" "this" {
  name = "${local.name}-irsa"

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
          "${replace(var.cluster_oidc, "arn:aws:iam::[0-9]*:oidc-provider/", "")}:sub" = "system:serviceaccount:${var.service_name}:${var.service_name}"
        }
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${local.name}-irsa"
    Team = var.team_name
  })
}

resource "aws_iam_role_policy" "this" {
  name = "${local.name}-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.service_name}-${var.environment}-data",
          "arn:aws:s3:::${var.service_name}-${var.environment}-data/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "arn:aws:sqs:*:*:${var.service_name}-${var.environment}"
      }
    ]
  })
}
