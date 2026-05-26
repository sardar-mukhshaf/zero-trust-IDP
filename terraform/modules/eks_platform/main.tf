locals {
  name = "${var.project_name}-${var.environment}"
}

resource "aws_iam_role" "cluster" {
  name = "${local.name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${local.name}-eks-cluster-role"
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
  ])

  policy_arn = each.value
  role       = aws_iam_role.cluster.name
}

resource "aws_eks_cluster" "this" {
  name     = "${local.name}-cluster"
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.private_subnets
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.cluster.id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policies,
  ]

  tags = merge(var.common_tags, {
    Name = "${local.name}-cluster"
  })
}

resource "aws_iam_openid_connect_provider" "this" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]

  tags = merge(var.common_tags, {
    Name = "${local.name}-oidc"
  })
}

data "tls_certificate" "this" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_security_group" "cluster" {
  name        = "${local.name}-eks-cluster-sg"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${local.name}-eks-cluster-sg"
  })
}

resource "aws_iam_role" "node_group" {
  name = "${local.name}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${local.name}-eks-node-group-role"
  })
}

resource "aws_iam_role_policy_attachment" "node_group_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ])

  policy_arn = each.value
  role       = aws_iam_role.node_group.name
}

resource "aws_eks_node_group" "platform_core" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.name}-platform-core"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.private_subnets

  instance_types = var.node_instance_types
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable_percentage = 25
  }

  labels = {
    workload = "platform-core"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_group_policies,
  ]

  tags = merge(var.common_tags, {
    Name = "${local.name}-platform-core"
  })
}

resource "aws_eks_node_group" "workloads" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.name}-workloads"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.private_subnets

  instance_types = var.node_instance_types
  capacity_type  = "SPOT"

  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 1
  }

  update_config {
    max_unavailable_percentage = 25
  }

  labels = {
    workload = "workloads"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_group_policies,
  ]

  tags = merge(var.common_tags, {
    Name = "${local.name}-workloads"
  })
}

resource "aws_iam_role" "irsa_backstage" {
  name = "${local.name}-irsa-backstage"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.this.arn
      }
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" = "system:serviceaccount:backstage:backstage"
        }
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${local.name}-irsa-backstage"
  })
}

resource "aws_iam_role" "irsa_tekton" {
  name = "${local.name}-irsa-tekton"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.this.arn
      }
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" = "system:serviceaccount:tekton-pipelines:tekton-pipelines-controller"
        }
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${local.name}-irsa-tekton"
  })
}

resource "aws_iam_role" "irsa_kubecost" {
  name = "${local.name}-irsa-kubecost"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.this.arn
      }
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" = "system:serviceaccount:kubecost:kubecost"
        }
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${local.name}-irsa-kubecost"
  })
}

resource "aws_iam_role" "irsa_cert_manager" {
  name = "${local.name}-irsa-cert-manager"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.this.arn
      }
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" = "system:serviceaccount:cert-manager:cert-manager"
        }
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${local.name}-irsa-cert-manager"
  })
}

resource "aws_iam_role" "irsa_secrets_csi" {
  name = "${local.name}-irsa-secrets-csi"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.this.arn
      }
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" = "system:serviceaccount:secrets-manager-csi:secrets-store-csi-driver"
        }
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${local.name}-irsa-secrets-csi"
  })
}
