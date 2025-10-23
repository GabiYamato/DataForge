# Spark Jobs

This folder contains streaming and batch PySpark jobs that process data from the landing and bronze zones into curated silver and gold datasets.

## Jobs

| File | Type | Purpose |
|------|------|---------|
| `streaming_enricher.py` | Structured Streaming | Consumes Kafka topics, validates events, writes bronze and silver parquet tables. |
| `daily_aggregator.py` | Batch | Aggregates previous-day metrics for gold serving tables. |
| `backfill_job.py` | Batch | Reprocesses historical partitions for remediation. |

## Local Testing

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
spark-submit --master local[2] streaming_enricher.py --env local
```

## Deployment

1. Upload scripts to S3 artefact bucket.
2. Create AWS Glue job (or EMR Serverless application) referencing the script location.
3. Configure job parameters (`--env`, `--checkpoint`, `--output-path`) matching environment.
4. Leverage Glue Workflows to schedule daily and backfill jobs.
