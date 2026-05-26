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
