# Incident Response Runbook

## Severity Levels

| Level | Description | Response Time | Examples |
|-------|-------------|---------------|----------|
| SEV1 | Platform outage | 15 minutes | EKS control plane down, all pipelines failing |
| SEV2 | Partial degradation | 30 minutes | Backstage unavailable, Keycloak auth failures |
| SEV3 | Single team impact | 1 hour | Team namespace quota exceeded, RDS latency |
| SEV4 | Minor issue | 4 hours | Policy exemption request, documentation gap |

## Common Incidents

### Gatekeeper Blocking Emergency Deployment
**Symptom:** Critical hotfix blocked by OPA constraint.
**Response:**
1. Identify violating constraint: `kubectl get constraints`
2. Temporarily exempt namespace (Platform admin only):
   ```bash
   kubectl label namespace <ns> gatekeeper.sh/exclude=true
   ```
3. Deploy hotfix.
4. Remove exemption within 24 hours and fix root cause.

### Istio mTLS Breaking Service Communication
**Symptom:** Services return 503 errors after deployment.
**Response:**
1. Check sidecar injection: `kubectl get pods -n <ns> -o jsonpath='{.items[*].spec.containers[*].name}'`
2. Verify PeerAuthentication: `kubectl get peerauthentication -A`
3. Check for conflicting DestinationRules.
4. If emergency, apply PERMISSIVE mode temporarily (document exception):
   ```yaml
   apiVersion: security.istio.io/v1beta1
   kind: PeerAuthentication
   metadata:
     name: emergency-permissive
     namespace: <ns>
   spec:
     mtls:
       mode: PERMISSIVE
   ```

### Terraform State Lock
**Symptom:** Pipeline fails with `Error acquiring the state lock`.
**Response:**
1. Identify lock owner: `aws dynamodb get-item --table-name ztidp-terraform-locks --key '{"LockID":{"S":"ztidp-terraform-state/environments/dev/terraform.tfstate-md5"}}'`
2. If stale (no active pipeline), force unlock:
   ```bash
   terraform force-unlock <LOCK_ID>
   ```
