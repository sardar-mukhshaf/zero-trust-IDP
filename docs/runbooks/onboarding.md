# Onboarding Runbook

## Onboard a New Engineering Team (30 Minutes)

### Prerequisites
- AWS CLI configured with platform-admin credentials
- `make` installed
- Access to Keycloak admin console (optional, for verification)

### Steps

1. **Set environment variables:**
   ```bash
   export TEAM=team-gamma
   export COST_CENTER=CC-GAMMA-005
   export OWNER=gamma-lead@example.com
   ```

2. **Run onboarding script:**
   ```bash
   make onboard-team TEAM=$TEAM
   ```

3. **Review generated configuration:**
   ```bash
   cat terraform/environments/dev/${TEAM}.tfvars
   ```

4. **Plan and apply infrastructure:**
   ```bash
   make plan ENV=dev
   make apply ENV=dev
   ```

5. **Verify Keycloak group:**
   - Login to `https://sso.yourdomain.com/admin`
   - Navigate to `platform-engineering` realm > Groups
   - Confirm `${TEAM}` exists with correct members

6. **Verify Backstage integration:**
   - Login to `https://portal.yourdomain.com`
   - Confirm team appears in OwnerPicker dropdown

7. **Verify Kubecost allocation:**
   - Navigate to `/allocations?agg=namespace`
   - Confirm `${TEAM}` namespace appears with cost center label

### Post-Onboarding
- Share team namespace name with developers
- Provide link to Golden Path templates
- Schedule 15-minute platform walkthrough
