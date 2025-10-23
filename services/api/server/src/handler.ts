import { APIGatewayProxyEventV2, APIGatewayProxyStructuredResultV2 } from "aws-lambda";

import { AlertsService } from "./services/alertsService.js";
import { MetricsService } from "./services/metricsService.js";
import { QueryService } from "./services/queryService.js";

const metricsService = new MetricsService();
const alertsService = new AlertsService();
const queryService = new QueryService();

export async function handler(event: APIGatewayProxyEventV2): Promise<APIGatewayProxyStructuredResultV2> {
  try {
    const method = event.requestContext.http.method;
    const path = event.rawPath ?? "/";

    if (method === "GET" && path === "/metrics") {
      const metrics = await metricsService.getLatestMetrics();
      return jsonResponse(200, { metrics });
    }

    if (method === "GET" && path === "/alerts") {
      const alerts = await alertsService.listRecentAlerts();
      return jsonResponse(200, { alerts });
    }

    if (method === "POST" && path === "/query") {
      const payload = event.body ? JSON.parse(event.body) : {};
      const sql = typeof payload.sql === "string" ? payload.sql : "";
      const result = await queryService.runQuery(sql);
      return jsonResponse(200, result);
    }

    return jsonResponse(404, { message: "Not Found" });
  } catch (error) {
    console.error("Unhandled error", error);
    return jsonResponse(500, { message: "Internal Server Error" });
  }
}

function jsonResponse(statusCode: number, body: unknown): APIGatewayProxyStructuredResultV2 {
  return {
    statusCode,
    body: JSON.stringify(body),
    headers: {
      "content-type": "application/json",
      "cache-control": "no-store",
    },
  };
}
