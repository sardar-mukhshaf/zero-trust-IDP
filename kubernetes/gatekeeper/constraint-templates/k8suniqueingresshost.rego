package k8suniqueingresshost

violation[{"msg": msg}] {
  input.review.object.kind == "Ingress"
  host := input.review.object.spec.rules[_].host
  other := data.inventory.namespace[_]["networking.k8s.io/v1"].Ingress[_]
  other.spec.rules[_].host == host
  other.metadata.namespace != input.review.object.metadata.namespace
  msg := sprintf("Ingress host %s already defined in namespace %s", [host, other.metadata.namespace])
}
