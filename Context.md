# DataForge Context

DataForge is a monorepo blueprint for an event-driven analytics platform built on AWS. The platform stitches together streaming and batch data ingestion, distributed storage, Spark-based transformations, and a real-time analytics experience delivered through serverless APIs and a React dashboard.

## High-Level Architecture

1. **Ingestion Plane**
   - Managed streaming backbone via Amazon MSK (Kafka) with schema registry.
   - AWS Lambda fan-out functions persist raw events to the landing zone and trigger downstream processes.
   - Batch sources (SFTP, S3 drops, JDBC) ingested via Kafka Connect and AWS Glue workflows.

2. **Storage & Transformation**
   - S3 data lake with tiered zones (landing, bronze, silver, gold). Versioning and lifecycle policies enforce durability.
   - Spark Structured Streaming jobs run on AWS Glue/EMR with checkpointing to S3. Batch jobs handle late-arriving data and dimensional modeling.
   - Glue Catalog maintains schema evolution; Athena/Redshift Spectrum provide ad-hoc query access.

3. **Analytics & APIs**
   - Aggregations stored in DynamoDB/Elasticache for fast reads.
   - Serverless TypeScript Lambdas exposed through API Gateway endpoints (`/metrics`, `/alerts`, `/query`).
   - React dashboard consumes APIs using React Query, WebSocket subscriptions, and renders KPIs, charts, and incident feeds.

4. **Observability**
   - CloudWatch metrics/alarms for throughput, lag, processing latency, and error rates.
   - Data quality checks using Deequ/Great Expectations integrated into Spark jobs.
   - Tracing via AWS X-Ray for API calls and Lambda executions.

## Non-Functional Goals

- **Scalability**: Elastic ingestion, horizontal scaling for EMR/Glue jobs, auto-scaling Lambdas.
- **Resilience**: Idempotent writes, retries with exponential backoff, DLQs for Lambda, partitioned checkpoints.
- **Security**: IAM least privilege, VPC endpoints, encryption with KMS keys, API authorizers.
- **Performance**: Dashboard refresh < 2s, Spark job SLA, Kafka lag monitoring.

## Development Expectations

- Use Terraform modules under `infrastructure/terraform` to provision AWS resources.
- Package Lambda functions via SAM/Serverless CLI with deployment scripts.
- Provide sample datasets and fixtures in `data/samples/` for local testing.
- Document runbooks and operational procedures in `docs/runbooks/`.

Keep this context in mind when extending or consuming components inside DataForge.
