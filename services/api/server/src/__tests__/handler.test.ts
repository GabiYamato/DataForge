import { describe, expect, it, vi } from "vitest";

import { handler } from "../handler.js";

vi.mock("../services/metricsService.js", () => ({
  MetricsService: class {
    async getLatestMetrics() {
      return [{ kpi: "test", value: 1, timestamp: "2024-01-01T00:00:00Z" }];
    }
  },
}));

vi.mock("../services/alertsService.js", () => ({
  AlertsService: class {
    async listRecentAlerts() {
      return [{ id: "a", severity: "info", message: "ok", timestamp: "2024", source: "test" }];
    }
  },
}));

vi.mock("../services/queryService.js", () => ({
  QueryService: class {
    async runQuery(sql: string) {
      return { sql, columns: ["c1"], rows: [["v"]], status: "SUCCEEDED" };
    }
  },
}));

describe("handler", () => {
  it("returns metrics for GET /metrics", async () => {
    const response = await handler({
      requestContext: { http: { method: "GET", path: "/metrics" } } as any,
      rawPath: "/metrics",
    } as any);

    expect(response.statusCode).toBe(200);
    expect(response.body).toContain("metrics");
  });

  it("returns alerts for GET /alerts", async () => {
    const response = await handler({
      requestContext: { http: { method: "GET", path: "/alerts" } } as any,
      rawPath: "/alerts",
    } as any);

    expect(response.statusCode).toBe(200);
    expect(response.body).toContain("alerts");
  });

  it("runs query for POST /query", async () => {
    const response = await handler({
      requestContext: { http: { method: "POST", path: "/query" } } as any,
      rawPath: "/query",
      body: JSON.stringify({ sql: "SELECT 1" }),
    } as any);

    expect(response.statusCode).toBe(200);
    expect(response.body).toContain("columns");
  });

  it("returns 404 for unknown route", async () => {
    const response = await handler({
      requestContext: { http: { method: "GET", path: "/unknown" } } as any,
      rawPath: "/unknown",
    } as any);

    expect(response.statusCode).toBe(404);
  });
});
