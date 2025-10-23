# Analytics API Lambda

Serverless TypeScript Lambda exposing metrics, alerts, and query endpoints for the DataForge dashboard.

## Commands

```bash
npm install
npm run lint
npm test
npm run build
```

`npm run build` bundles `src/handler.ts` into `dist/handler.js` via tsup for deployment.

## Environment Variables

- `METRICS_TABLE`: DynamoDB table storing KPI time series.
- `ALERTS_TOPIC_ARN`: SNS topic for alerts (used for routing metadata).
- `ATHENA_WORKGROUP`: Athena workgroup for ad-hoc queries.
- `ATHENA_OUTPUT`: S3 path for Athena result sets.

## Deployment

1. Build artifact `npm run build`.
2. Zip contents of `dist/` directory for Terraform `api_lambda_package` variable.
3. Update Terraform variables to point to generated zip.
