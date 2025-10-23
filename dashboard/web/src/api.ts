import axios from "axios";

const client = axios.create({
  baseURL: import.meta.env.VITE_API_BASE ?? "http://localhost:3000",
  timeout: 2_000,
});

export interface MetricPoint {
  kpi: string;
  value: number;
  unit?: string;
  timestamp: string;
}

export interface Alert {
  id: string;
  severity: string;
  message: string;
  timestamp: string;
  source: string;
}

export interface QueryResult {
  columns: string[];
  rows: string[][];
  status: string;
}

export async function fetchMetrics(): Promise<MetricPoint[]> {
  const response = await client.get<{ metrics: MetricPoint[] }>("/metrics");
  return response.data.metrics;
}

export async function fetchAlerts(): Promise<Alert[]> {
  const response = await client.get<{ alerts: Alert[] }>("/alerts");
  return response.data.alerts;
}

export async function runQuery(sql: string): Promise<QueryResult> {
  const response = await client.post<QueryResult>("/query", { sql });
  return response.data;
}
