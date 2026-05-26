package k8s.nolatestimage

deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  endswith(container.image, ":latest")
  msg := sprintf("Container %s in Deployment %s uses forbidden 'latest' tag", [container.name, input.metadata.name])
}

deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not contains(container.image, ":")
  msg := sprintf("Container %s in Deployment %s must specify an image tag", [container.name, input.metadata.name])
}
