locals {
  name = "${var.project_name}-${var.environment}"
}

resource "helm_release" "kubecost" {
  name       = "kubecost"
  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "cost-analyzer"
  namespace  = "kubecost"
  version    = var.kubecost_version
  create_namespace = true

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      allocation_labels = var.allocation_labels
      aws_payer_account_id = var.aws_payer_account_id
      budget_threshold = var.budget_threshold_usd
    })
  ]
}

resource "kubernetes_manifest" "namespace_allocation" {
  manifest = {
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name      = "namespace-allocation"
      namespace = "kubecost"
    }
    data = {
      "allocation.json" = jsonencode({
        teams = [
          {
            name        = "team-backend"
            cost_center = "CC-BACKEND-001"
            namespaces  = ["team-backend"]
          },
          {
            name        = "team-frontend"
            cost_center = "CC-FRONTEND-002"
            namespaces  = ["team-frontend"]
          },
          {
            name        = "team-data"
            cost_center = "CC-DATA-003"
            namespaces  = ["team-data"]
          },
          {
            name        = "team-sre"
            cost_center = "CC-SRE-004"
            namespaces  = ["team-sre"]
          }
        ]
      })
    }
  }
}
