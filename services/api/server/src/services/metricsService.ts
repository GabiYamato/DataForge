import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb";

import { METRICS_TABLE } from "../config.js";

export interface MetricPoint {
  kpi: string;
  value: number;
  timestamp: string;
  unit?: string;
}

export class MetricsService {
  private readonly docClient: DynamoDBDocumentClient;

  constructor(client?: DynamoDBDocumentClient) {
    const dynamo = client ?? this.buildClient();
    this.docClient = dynamo;
  }

  async getLatestMetrics(limit = 10): Promise<MetricPoint[]> {
    const command = new QueryCommand({
      TableName: METRICS_TABLE,
      KeyConditionExpression: "pk = :pk",
      ExpressionAttributeValues: {
        ":pk": "metrics",
      },
      ScanIndexForward: false,
      Limit: limit,
    });

    try {
      const result = await this.docClient.send(command);
      return (
        result.Items?.map((item: Record<string, unknown>) => ({
          kpi: String(item.sk ?? "unknown"),
          value: Number(item.value ?? 0),
          timestamp: String(item.timestamp ?? new Date().toISOString()),
          unit: item.unit ? String(item.unit) : undefined,
        })) ?? []
      );
    } catch (error) {
      console.warn("Falling back to canned metrics", error);
      return this.fallback();
    }
  }

  private buildClient(): DynamoDBDocumentClient {
    const client = new DynamoDBClient({});
    return DynamoDBDocumentClient.from(client);
  }

  private fallback(): MetricPoint[] {
    const now = new Date();
    return [
      { kpi: "ingestion.lag.ms", value: 42, timestamp: now.toISOString(), unit: "ms" },
      { kpi: "spark.runtime.sec", value: 128, timestamp: now.toISOString(), unit: "sec" },
      { kpi: "api.p95.latency.ms", value: 950, timestamp: now.toISOString(), unit: "ms" },
    ];
  }
}
