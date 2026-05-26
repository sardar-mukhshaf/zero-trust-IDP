package k8sblocknodeport

violation[{"msg": msg}] {
  input.review.object.spec.type == "NodePort"
  msg := "NodePort services are forbidden. Use ClusterIP with Istio Ingress."
}
