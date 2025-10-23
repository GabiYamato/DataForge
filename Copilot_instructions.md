# Copilot Instructions

These guidelines tune coding agents collaborating on DataForge. Follow them to keep the platform coherent, resilient, and production-ready.

## Priorities

1. Uphold the platform requirements: multi-source ingestion, reliable transformations, real-time APIs, sub-2s dashboard refresh, and observability.
2. Design for AWS-first deployment (S3, Lambda, MSK/Kafka, Glue/EMR, API Gateway). Prefer managed services over self-hosted alternatives.
3. Keep infrastructure, data pipelines, backend, and dashboard code modular with clear ownership boundaries.
4. Enforce data quality, monitoring, and security (encryption, least privilege IAM) in every change.
5. Maintain testability: add unit/integration tests, sample data, and mocks to validate behavior locally.

## Coding Conventions

- **Languages**: Infrastructure (Terraform + HCL), backend (TypeScript/Node for Lambdas), data jobs (Python + PySpark), frontend (React + TypeScript), automation (Bash or Python).
- **Style**: Use linted, idiomatic code. Prefer dependency injection patterns for testability. Document non-obvious logic with concise comments.
- **Config**: Centralize environment variables in `env.example` files and reference via runtime configuration (Secrets Manager/SSM in production).
- **Error handling**: Fail fast with contextual logging. Surface operational metrics via CloudWatch or Prometheus exporters.
- **CI/CD**: Assume GitHub Actions automation. Place workflows in `.github/workflows/` and keep jobs idempotent.

## Collaboration

- Break work into small commits (`vX.Y.Z (description)`).
- Update architecture docs when adding or modifying significant components.
- When adding new data sources or dashboards, document lineage and refresh cadence.
- Always provide verification steps (tests, lint, terraform plan) in PR descriptions.

## Security & Compliance

- Encrypt data at rest (S3 bucket policies, SSE-KMS) and in transit (HTTPS, TLS for Kafka).
- Mask secrets in code and config. Rely on AWS Secrets Manager or SSM Parameter Store.
- Log access and processing events for auditing. Retain logs per compliance bucket policy.
- Implement role-based access via IAM/Cognito; document roles/permissions.

## Performance

- Target ingestion < 5s end-to-end latency for streaming feeds.
- Maintain Spark job p99 processing < 2x data arrival interval.
- Ensure API latency p95 < 2s under expected load; monitor via CloudWatch Alarms.
- Use caching (DynamoDB DAX, API Gateway cache) when redressing repeated queries.

## Deliverables Checklist

- Code + IaC updates
- Tests and sample datasets
- Documentation updates (README, architecture diagrams, runbooks)
- Monitoring and alerting hooks
- Deployment scripts/instructions

Stay aligned with these instructions to deliver production-grade contributions.
