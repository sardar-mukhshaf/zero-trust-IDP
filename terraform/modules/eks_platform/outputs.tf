output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_cert" {
  description = "EKS cluster CA certificate"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  description = "OIDC provider URL"
  value       = aws_iam_openid_connect_provider.this.url
}

output "platform_core_node_group" {
  description = "Platform core node group name"
  value       = aws_eks_node_group.platform_core.node_group_name
}

output "workloads_node_group" {
  description = "Workloads node group name"
  value       = aws_eks_node_group.workloads.node_group_name
}
