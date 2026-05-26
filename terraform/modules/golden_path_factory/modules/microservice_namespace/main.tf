resource "kubernetes_namespace" "this" {
  metadata {
    name = var.service_name
    labels = merge(var.common_tags, {
      "app.kubernetes.io/name" = var.service_name
      team                     = var.team_name
      "cost-center"            = var.cost_center
      environment              = var.environment
      owner                    = var.team_name
      istio-injection          = "enabled"
    })
  }
}

resource "kubernetes_resource_quota" "this" {
  metadata {
    name      = "${var.service_name}-quota"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    hard = var.namespace_resource_quota
  }
}

resource "kubernetes_limit_range" "this" {
  metadata {
    name      = "${var.service_name}-limits"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = "500m"
        memory = "512Mi"
      }
      default_request = {
        cpu    = "100m"
        memory = "128Mi"
      }
    }
  }
}

resource "kubernetes_role" "this" {
  metadata {
    name      = "${var.service_name}-role"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  rule {
    api_groups = ["", "apps", "networking.k8s.io"]
    resources  = ["pods", "services", "deployments", "configmaps", "secrets", "ingresses"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding" "this" {
  metadata {
    name      = "${var.service_name}-rolebinding"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.this.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = var.team_name
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_network_policy" "deny_all" {
  metadata {
    name      = "default-deny-all"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_network_policy" "allow_istio" {
  metadata {
    name      = "allow-istio-ingress"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]
    ingress {
      from {
        namespace_selector {
          match_labels = {
            "app.kubernetes.io/name" = "istio-system"
          }
        }
      }
    }
  }
}
