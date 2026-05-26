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

violation[{"msg": msg}] {
  container := input.review.object.spec.containers[_]
  not container.securityContext.readOnlyRootFilesystem
  msg := sprintf("Container %s must set readOnlyRootFilesystem: true", [container.name])
}

violation[{"msg": msg}] {
  container := input.review.object.spec.containers[_]
  not container.securityContext.capabilities.drop
  msg := sprintf("Container %s must drop ALL capabilities", [container.name])
}
