output "namespace_names" {
  description = "Created namespace names"
  value       = [for ns in module.microservice_namespace : ns.namespace_name]
}
