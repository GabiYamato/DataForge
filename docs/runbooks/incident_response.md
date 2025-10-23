# Incident Response Runbook

## Purpose

Provide actionable steps when DataForge experiences ingestion failures, elevated processing latency, or analytics downtime. Use this playbook to triage quickly and restore SLA compliance.

## Communication

- Declare incidents in the `#dataforge-incident` Slack channel and tag on-call engineers.
- Record timeline and actions in the incident ticket (Jira DFG-INC-###).
- Provide status updates every 15 minutes during SEV1 incidents.

## Ingestion Failures

1. **Detect**: CloudWatch Alarm `IngestionErrorRateHigh` or Kafka lag > threshold.
2. **Triage**:
   - Check Lambda DLQ for recent messages (`aws sqs receive-message`).
   - Inspect AWS Lambda CloudWatch logs for stack traces.
   - Verify MSK connectivity and broker health via `kafka-consumer-groups.sh`.
3. **Mitigate**:
   - Replay DLQ messages using `services/ingestion/lambdas/replay_dlq.py`.
   - Scale out Lambda concurrency or MSK partitions if saturation observed.
   - If schema validation fails, coordinate with data producer; apply temporary schema override if approved.
4. **Recover**:
   - Backfill missing data by running `services/transformation/spark-jobs/backfill_job.py` for the affected window.
   - Close incident once ingestion metrics return to baseline.

## Processing Latency

1. **Detect**: CloudWatch Alarm `SparkProcessingLatencyHigh` or Glue job SLA breach.
2. **Triage**:
   - Review Glue job run history and logs.
   - Inspect Spark checkpoint directory for corrupt metadata.
   - Verify upstream ingestion volume spikes or schema drift.
3. **Mitigate**:
   - Increase Glue/EMR worker count; trigger autoscaling via Terraform variable overrides.
   - Reprocess stuck micro-batches by deleting the offending checkpoint file (document action).
   - Disable heavy optional transformations to relieve load; track resulting data gaps.
4. **Recover**:
   - Run targeted backfill jobs.
   - Update incident ticket with root cause and remediation tasks.

## API/Dashboard Outage

1. **Detect**: API Gateway `5XXErrorRate` alarm or synthetic test failure.
2. **Triage**:
   - Check recent Lambda deployments (CodeDeploy/alias traffic shifting rollback if needed).
   - Review DynamoDB metrics for throttling and adjust RCUs/auto scaling.
   - Inspect CloudFront/S3 status for dashboard hosting.
3. **Mitigate**:
   - Roll back Lambda to previous stable version (`aws lambda update-alias`).
   - Enable API Gateway caching fallback.
   - Serve static maintenance page if outage persists.
4. **Recover**:
   - Validate APIs using Postman collection.
   - Confirm dashboard refresh latency within SLA.

## Post-Incident

- Conduct blameless postmortem within 48 hours.
- Update runbooks, tests, and automation to prevent recurrence.
- Track corrective actions in Jira with owners and due dates.
