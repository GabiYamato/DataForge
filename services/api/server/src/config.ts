export const METRICS_TABLE = process.env.METRICS_TABLE ?? "dataforge-metrics";
export const ALERTS_TOPIC_ARN = process.env.ALERTS_TOPIC_ARN ?? "arn:aws:sns:us-east-1:123456789012:dataforge-alerts";
export const ATHENA_WORKGROUP = process.env.ATHENA_WORKGROUP ?? "primary";
export const ATHENA_OUTPUT = process.env.ATHENA_OUTPUT ?? "s3://dataforge-athena-results";
