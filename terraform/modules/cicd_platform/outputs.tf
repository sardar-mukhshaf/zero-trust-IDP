output "tekton_namespace" {
  description = "Tekton namespace"
  value       = kubernetes_namespace.tekton_pipelines.metadata[0].name
}

output "tekton_irsa_role_arn" {
  description = "Tekton IRSA role ARN"
  value       = aws_iam_role.tekton_irsa.arn
}
