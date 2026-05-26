kubecostProductConfigs:
  clusterName: ${cluster_name}
  currencyCode: "USD"
  defaultTeamId: "platform"

prometheus:
  server:
    retention: "30d"
    persistentVolume:
      enabled: true
      size: 32Gi

costAllocation:
  sharedNamespaces: "kube-system,istio-system,cert-manager,gatekeeper-system"
  sharedLabelNames: "team,cost-center"
  sharedLabelValues: "platform,CC-PLATFORM-000"

notifications:
  alertConfigs:
    enabled: true
    globalAlertEmails:
      - platform-alerts@example.com
    alerts:
      - type: budget
        threshold: ${budget_threshold}
        window: 1d
        aggregation: namespace
      - type: spendChange
        relativeThreshold: 0.50
        window: 7d
        aggregation: namespace

aws:
  payerAccountID: "${aws_payer_account_id}"
  cur:
    enabled: true
    bucketName: "${aws_payer_account_id}-cur-reports"
    region: "us-east-1"
    prefix: "daily-cur/"

reporting:
  exportToCSV:
    enabled: true
    storage:
      enabled: true
      bucketName: "${cluster_name}-kubecost-reports"
