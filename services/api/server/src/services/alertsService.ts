export interface Alert {
  id: string;
  severity: "info" | "warning" | "critical";
  message: string;
  timestamp: string;
  source: string;
}

export class AlertsService {
  async listRecentAlerts(limit = 20): Promise<Alert[]> {
    const now = Date.now();
    return Array.from({ length: Math.min(limit, 5) }, (_, index) => ({
      id: `alert-${index}`,
      severity: index % 2 === 0 ? "warning" : "info",
      message: index % 2 === 0 ? "Kafka consumer lag exceeded threshold" : "Spark job completed",
      timestamp: new Date(now - index * 60_000).toISOString(),
      source: index % 2 === 0 ? "ingestion" : "transformation",
    }));
  }
}
