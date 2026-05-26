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
