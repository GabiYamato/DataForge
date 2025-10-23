# Kafka Connect Sources

This directory hosts declarative configurations for Kafka Connect connectors used to ingest batch and streaming feeds into Amazon MSK. Deploy configurations via Confluent Hub, MSK Connect, or self-managed Connect clusters.

## Connectors

| File | Type | Description |
|------|------|-------------|
| `jdbc_source.json` | Source | Streams operational DB tables via incremental snapshots. |
| `s3_batch_source.json` | Source | Loads periodic S3 object drops into Kafka for normalization. |
| `sftp_source.json` | Source | Ingests CSV files from partner SFTP servers on schedule. |

## Deployment

1. Provision MSK Connect worker pool with IAM role allowing access to source systems and MSK cluster.
2. Apply the connector config (update placeholders) via AWS Console or CLI:
   ```bash
   aws msk-connect create-connector \
     --capacity autoScaling={maxWorkerCount=6,minWorkerCount=2,mcuCount=1} \
     --connector-name dataforge-jdbc-source \
     --kafkaconnect-version 2.7.1 \
     --connector-configuration file://jdbc_source.json \
     --kafka-cluster "{\"apacheKafkaCluster\":{\"vpc\":{\"subnets\":[...],\"securityGroups\":[...]},\"bootstrapServers\":\"b-1...\"}}" \
     --service-execution-role-arn arn:aws:iam::123456789012:role/DataForgeConnectRole
   ```
3. Confirm status `RUNNING` and monitor lag via CloudWatch metrics (`KafkaConnectWorker` namespace).

Update configs whenever schemas evolve or new data sources are onboarded.
