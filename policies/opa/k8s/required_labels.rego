package k8s.requiredlabels

deny[msg] {
  input.kind == "Pod"
  required := {"app.kubernetes.io/name", "team", "cost-center", "environment", "owner"}
  provided := {label | input.metadata.labels[label]}
  missing := required - provided
  count(missing) > 0
  msg := sprintf("Pod %s missing required labels: %v", [input.metadata.name, missing])
}

deny[msg] {
  input.kind == "Deployment"
  required := {"app.kubernetes.io/name", "team", "cost-center", "environment", "owner"}
  provided := {label | input.metadata.labels[label]}
  missing := required - provided
  count(missing) > 0
  msg := sprintf("Deployment %s missing required labels: %v", [input.metadata.name, missing])
}
