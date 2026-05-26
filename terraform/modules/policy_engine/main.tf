locals {
  name = "${var.project_name}-${var.environment}"
}

resource "helm_release" "gatekeeper" {
  name       = "gatekeeper"
  repository = "https://open-policy-agent.github.io/gatekeeper/charts"
  chart      = "gatekeeper"
  namespace  = "gatekeeper-system"
  version    = var.gatekeeper_version
  create_namespace = true

  set {
    name  = "enableDeleteOperations"
    value = "true"
  }

  set {
    name  = "auditInterval"
    value = "60"
  }

  set {
    name  = "constraintViolationsLimit"
    value = "50"
  }
}

resource "kubernetes_manifest" "constraint_template_required_labels" {
  manifest = {
    apiVersion = "templates.gatekeeper.sh/v1"
    kind       = "ConstraintTemplate"
    metadata = {
      name = "k8srequiredlabels"
    }
    spec = {
      crd = {
        spec = {
          names = {
            kind = "K8sRequiredLabels"
          }
          validation = {
            openAPIV3Schema = {
              type = "object"
              properties = {
                labels = {
                  type = "array"
                  items = {
                    type = "string"
                  }
                }
              }
            }
          }
        }
      }
      targets = [{
        target = "admission.k8s.gatekeeper.sh"
        rego = <<EOF
package k8srequiredlabels

violation[{"msg": msg}] {
  provided := {label | input.review.object.metadata.labels[label]}
  required := {label | label := input.parameters.labels[_]}
  missing := required - provided
  count(missing) > 0
  msg := sprintf("Missing required labels: %v", [missing])
}
EOF
      }]
    }
  }

  depends_on = [helm_release.gatekeeper]
}

resource "kubernetes_manifest" "constraint_template_required_resources" {
  manifest = {
    apiVersion = "templates.gatekeeper.sh/v1"
    kind       = "ConstraintTemplate"
    metadata = {
      name = "k8srequiredresources"
    }
    spec = {
      crd = {
        spec = {
          names = {
            kind = "K8sRequiredResources"
          }
        }
      }
      targets = [{
        target = "admission.k8s.gatekeeper.sh"
        rego = <<EOF
package k8srequiredresources

violation[{"msg": msg}] {
  container := input.review.object.spec.containers[_]
  not container.resources.limits.cpu
  msg := sprintf("Container %s must have CPU limits", [container.name])
}

violation[{"msg": msg}] {
  container := input.review.object.spec.containers[_]
  not container.resources.limits.memory
  msg := sprintf("Container %s must have memory limits", [container.name])
}

violation[{"msg": msg}] {
  container := input.review.object.spec.containers[_]
  not container.resources.requests.cpu
  msg := sprintf("Container %s must have CPU requests", [container.name])
}

violation[{"msg": msg}] {
  container := input.review.object.spec.containers[_]
  not container.resources.requests.memory
  msg := sprintf("Container %s must have memory requests", [container.name])
}
EOF
      }]
    }
  }

  depends_on = [helm_release.gatekeeper]
}

resource "kubernetes_manifest" "constraint_template_no_latest_image" {
  manifest = {
    apiVersion = "templates.gatekeeper.sh/v1"
    kind       = "ConstraintTemplate"
    metadata = {
      name = "k8snolatestimage"
    }
    spec = {
      crd = {
        spec = {
          names = {
            kind = "K8sNoLatestImage"
          }
        }
      }
      targets = [{
        target = "admission.k8s.gatekeeper.sh"
        rego = <<EOF
package k8snolatestimage

violation[{"msg": msg}] {
  container := input.review.object.spec.containers[_]
  endswith(container.image, ":latest")
  msg := sprintf("Container %s uses forbidden 'latest' tag", [container.name])
}

violation[{"msg": msg}] {
  container := input.review.object.spec.containers[_]
  not contains(container.image, ":")
  msg := sprintf("Container %s must specify an image tag", [container.name])
}
EOF
      }]
    }
  }

  depends_on = [helm_release.gatekeeper]
}

resource "kubernetes_manifest" "constraint_template_no_root_user" {
  manifest = {
    apiVersion = "templates.gatekeeper.sh/v1"
    kind       = "ConstraintTemplate"
    metadata = {
      name = "k8snorootuser"
    }
    spec = {
      crd = {
        spec = {
          names = {
            kind = "K8sNoRootUser"
          }
        }
      }
      targets = [{
        target = "admission.k8s.gatekeeper.sh"
        rego = <<EOF
package k8snorootuser

violation[{"msg": msg}] {
  container := input.review.object.spec.containers[_]
  not container.securityContext.runAsNonRoot
  msg := sprintf("Container %s must set runAsNonRoot: true", [container.name])
}

violation[{"msg": msg}] {
  container := input.review.object.spec.containers[_]
  container.securityContext.allowPrivilegeEscalation == true
  msg := sprintf("Container %s must not allow privilege escalation", [container.name])
}
EOF
      }]
    }
  }

  depends_on = [helm_release.gatekeeper]
}

resource "kubernetes_manifest" "constraint_required_labels" {
  manifest = {
    apiVersion = "constraints.gatekeeper.sh/v1beta1"
    kind       = "K8sRequiredLabels"
    metadata = {
      name = "require-platform-labels"
    }
    spec = {
      match = {
        kinds = [{
          apiGroups = [""]
          kinds     = ["Pod", "Deployment", "Service"]
        }]
        scope = "Namespaced"
      }
      parameters = {
        labels = [
          "app.kubernetes.io/name",
          "team",
          "cost-center",
          "environment",
          "owner"
        ]
      }
    }
  }

  depends_on = [kubernetes_manifest.constraint_template_required_labels]
}

resource "kubernetes_manifest" "constraint_required_resources" {
  manifest = {
    apiVersion = "constraints.gatekeeper.sh/v1beta1"
    kind       = "K8sRequiredResources"
    metadata = {
      name = "require-resource-limits"
    }
    spec = {
      match = {
        kinds = [{
          apiGroups = ["apps"]
          kinds     = ["Deployment"]
        }]
        scope = "Namespaced"
      }
    }
  }

  depends_on = [kubernetes_manifest.constraint_template_required_resources]
}

resource "kubernetes_manifest" "constraint_no_latest_image" {
  manifest = {
    apiVersion = "constraints.gatekeeper.sh/v1beta1"
    kind       = "K8sNoLatestImage"
    metadata = {
      name = "no-latest-image"
    }
    spec = {
      match = {
        kinds = [{
          apiGroups = ["apps"]
          kinds     = ["Deployment"]
        }]
        scope = "Namespaced"
      }
    }
  }

  depends_on = [kubernetes_manifest.constraint_template_no_latest_image]
}

resource "kubernetes_manifest" "constraint_no_root_user" {
  manifest = {
    apiVersion = "constraints.gatekeeper.sh/v1beta1"
    kind       = "K8sNoRootUser"
    metadata = {
      name = "no-root-user"
    }
    spec = {
      match = {
        kinds = [{
          apiGroups = ["apps"]
          kinds     = ["Deployment"]
        }]
        scope = "Namespaced"
      }
    }
  }

  depends_on = [kubernetes_manifest.constraint_template_no_root_user]
}
