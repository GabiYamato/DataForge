# DataForge Architecture

```
+----------------------+         +----------------------+         +--------------------------+
| External Producers   |  --->   | Amazon MSK (Kafka)   |  --->   | AWS Lambda (fan-out)     |
|  - IoT telemetry     |         |  - Source topics     |         |  - Raw S3 landing writes  |
|  - SaaS webhooks     |         |  - Dead-letter topics|         |  - Quality metrics emit   |
+----------------------+         +----------------------+         +--------------------------+
                                                                   |
                                                                   v
                                                          +-------------------+
                                                          | S3 Data Lake      |
                                                          |  Landing (raw)    |
                                                          |  Bronze (parsed)  |
                                                          |  Silver (curated) |
                                                          |  Gold (serving)   |
                                                          +-------------------+
                                                                   |
                                                                   v
                                                   +-------------------------------+
                                                   | Apache Spark (Glue/EMR)       |
                                                   |  - Streaming ETL (Structured) |
                                                   |  - Batch enrichment jobs      |
                                                   |  - Quality checks (Deequ)     |
                                                   +-------------------------------+
                                                                   |
                                                                   v
                                        +-------------------------+      +----------------------+
                                        | DynamoDB / Athena Views |      | CloudWatch Metrics   |
                                        |  - Aggregated KPIs      |      |  - Throughput        |
                                        |  - Query cache          |      |  - Latency           |
                                        +-------------------------+      +----------------------+
                                                    |                                |
                                                    v                                v
                                            +-------------------+            +-----------------+
                                            | AWS API Gateway   |<---------->| AWS Lambda (API)|
                                            |  REST + WebSocket |            |  TypeScript     |
                                            +-------------------+            +-----------------+
                                                    |
                                                    v
                                           +---------------------+
                                           | React Dashboard     |
                                           |  - KPIs, charts     |
                                           |  - Alert feed       |
                                           |  - Custom queries   |
                                           +---------------------+
```

## Component Breakdown

### Ingestion Layer

- **Kafka Producers**: External systems publish JSON/Avro events to dedicated topics. Producers authenticate via IAM + MSK IAM SASL.
- **Schema Registry**: Confluent-compatible registry enforces schema evolution and compatibility.
- **Kafka Connect**: Source connectors ingest batch loads (JDBC, S3, SFTP) into Kafka with offset tracking. Sink connectors push curated data to downstream services when necessary.
- **AWS Lambda Fan-out**: EventBridge triggers Lambda functions per topic partition to persist raw payloads to S3 landing buckets and emit quality metrics (record count, schema validation results).

### Storage & Processing

- **S3 Data Lake**: Organized into `landing/`, `bronze/`, `silver/`, `gold/` prefixes with bucket-level encryption (SSE-KMS) and object versioning. Lifecycle policies transition outdated data to Glacier.
- **Glue Data Catalog**: Centralizes schemas for Spark, Athena, and Redshift Spectrum. Partition metadata stored for efficient pruning.
- **Spark Jobs**:
  - *Streaming*: Structured Streaming jobs read from MSK, apply cleansing and enrichment, and write to `bronze`/`silver` zones with checkpointing.
  - *Batch*: Nightly jobs reconcile late-arriving data, build aggregates, and materialize `gold` tables. Jobs orchestrated via AWS Glue Workflows.
  - *Data Quality*: Deequ/Great Expectations suites run during writes; failures trigger SNS notifications and route records to quarantine buckets.

### Analytics Services

- **Serving Layer**: Aggregated KPIs persisted to DynamoDB tables, while ad-hoc query access is provided via Athena views over `gold` data.
- **API Layer**: AWS Lambda handlers (TypeScript) expose REST endpoints:
  - `GET /metrics` – streaming KPIs with optional WebSocket upgrade.
  - `GET /alerts` – latest quality or SLA breaches.
  - `POST /query` – parameterized analytics executed against Athena and cached.
- **Authentication & Authorization**: API Gateway custom authorizers integrate with Amazon Cognito (roadmap) to enforce role-based access.

### Visualization Layer

- **React Dashboard**: Vite + React + TypeScript app with modular widgets (KPI tiles, Sparkline charts, anomaly timeline). Uses React Query for API polling and WebSocket hooks for push updates.
- **Performance Goals**: Dashboard refresh under 2 seconds achieved via optimized API responses, caching, and client-side virtualization.

### Observability & Reliability

- **Metrics**: Pipeline emits metrics to CloudWatch (ingestion lag, processing latency, error counts) and Prometheus (via exporters). Dashboards present SLA compliance.
- **Logging**: Centralized via CloudWatch Logs and Kinesis Firehose to S3 for long-term retention.
- **Alerting**: CloudWatch Alarms and SNS topics notify on SLA breaches; runbooks in `docs/runbooks/` detail response steps.
- **Resilience**: Idempotent writes, DLQs per Lambda, retry policies, and automated data backfills for missing partitions.

## Deployment Flow

1. Provision core infrastructure with Terraform (VPC, MSK, S3, Glue, IAM, API Gateway skeleton).
2. Deploy Lambda functions via SAM/Serverless, injecting environment variables from SSM Parameter Store.
3. Submit Spark jobs to AWS Glue using job scripts in `services/transformation/spark-jobs`.
4. Publish the React dashboard to S3 + CloudFront or Amplify for global distribution.

Keep this document updated when introducing new services, data domains, or observability tooling.
