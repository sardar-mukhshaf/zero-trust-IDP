# ${{ values.service_name }}

Welcome to the **${{ values.service_name }}** microservice documentation.

## Overview

This service was generated using the **Golden Path Microservice** template.

## Team

- **Team**: ${{ values.team_name }}
- **Owner**: ${{ values.owner }}

## Architecture

```mermaid
graph LR
    A[Istio Ingress] --> B[${{ values.service_name }}]
    B --> C[(Database)]
    B --> D[(S3)]
    B --> E[(SQS)]
```

## Getting Started

1. Clone the repository
2. Run `make dev` to start locally
3. Run `make test` to execute tests

## Infrastructure

| Resource | Status |
|----------|--------|
| Namespace | ${{ values.team_name }} |
| Database | ${{ values.db_type }} |
| Queue | ${{ values.queue_type }} |
| S3 | ${{ values.enable_s3 }} |

## CI/CD

This service uses Tekton for continuous integration and deployment.
Pipeline: `microservice-build-and-deploy`
