# OPA Policy Guide

## Kubernetes Policies

### K8sRequiredLabels
Ensures all workloads have platform-mandated labels for ownership, cost allocation, and traceability.

**Required Labels:**
- `app.kubernetes.io/name`
- `team`
- `cost-center`
- `environment`
- `owner`

**Example Violation:**
```yaml
# Denied - missing cost-center and owner
metadata:
  labels:
    app.kubernetes.io/name: my-service
    team: backend
    environment: dev
```

### K8sRequiredResources
Prevents resource starvation by enforcing CPU and memory limits/requests.

**Example Violation:**
```yaml
# Denied - no memory limits
resources:
  limits:
    cpu: 500m
```

### K8sNoLatestImage
Prevents non-deterministic deployments by banning the `latest` tag.

### K8sNoRootUser
Enforces container hardening standards.

### K8sBlockNodePort
Forces all external traffic through Istio Ingress Gateway.

### K8sUniqueIngressHost
Prevents routing conflicts across namespaces.

## Terraform Policies

### no_public_s3
Blocks any S3 bucket that allows public access.

### encryption_required
Requires encryption at rest for EBS, RDS, and S3.

### required_tags
Enforces cost allocation and ownership tags on all AWS resources.
