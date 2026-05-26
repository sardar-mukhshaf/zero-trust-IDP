locals {
  name = "${var.project_name}-${var.environment}"
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = "istio-system"
  version    = var.istio_version
  create_namespace = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = "istio-system"
  version    = var.istio_version

  set {
    name  = "meshConfig.defaultConfig.holdApplicationUntilProxyStarts"
    value = "true"
  }

  set {
    name  = "global.proxy.holdApplicationUntilProxyStarts"
    value = "true"
  }

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = "istio-system"
  version    = var.istio_version

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  depends_on = [helm_release.istiod]
}

resource "kubernetes_manifest" "peer_authentication_mesh" {
  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "PeerAuthentication"
    metadata = {
      name      = "default"
      namespace = "istio-system"
    }
    spec = {
      mtls = {
        mode = var.mtls_mode
      }
    }
  }

  depends_on = [helm_release.istiod]
}

resource "kubernetes_manifest" "authorization_policy_deny_all" {
  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "deny-all"
      namespace = "istio-system"
    }
    spec = {}
  }

  depends_on = [helm_release.istiod]
}

resource "kubernetes_manifest" "authorization_policy_backstage" {
  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "allow-backstage"
      namespace = "backstage"
    }
    spec = {
      selector = {
        matchLabels = {
          app = "backstage"
        }
      }
      action = "ALLOW"
      rules = [
        {
          from = [{
            source = {
              namespaces = ["istio-system"]
            }
          }]
          to = [{
            operation = {
              methods = ["GET", "POST", "PUT", "DELETE"]
              paths   = ["/api/*", "/catalog/*", "/create/*"]
            }
          }]
        }
      ]
    }
  }

  depends_on = [helm_release.istiod]
}
