import {
  AthenaClient,
  GetQueryExecutionCommand,
  GetQueryResultsCommand,
  QueryExecutionState,
  StartQueryExecutionCommand,
} from "@aws-sdk/client-athena";

import { ATHENA_OUTPUT, ATHENA_WORKGROUP } from "../config.js";

export interface QueryResponse {
  columns: string[];
  rows: string[][];
  status: QueryExecutionState;
}

export class QueryService {
  private readonly client: AthenaClient;

  constructor(client?: AthenaClient) {
    this.client = client ?? new AthenaClient({});
  }

  async runQuery(sql: string): Promise<QueryResponse> {
    if (!sql.trim()) {
      throw new Error("Query cannot be empty");
    }

    const startId = await this.start(sql);
    const status = await this.waitForCompletion(startId);

    if (status !== QueryExecutionState.SUCCEEDED) {
      return { columns: [], rows: [], status };
    }

    const results = await this.client.send(
      new GetQueryResultsCommand({ QueryExecutionId: startId })
    );

    const columns =
      results.ResultSet?.ResultSetMetadata?.ColumnInfo?.map((info: { Name?: string }) => info.Name ?? "") ?? [];
    const rows =
      results.ResultSet?.Rows?.slice(1).map((row: { Data?: { VarCharValue?: string }[] }) =>
        row.Data?.map((col: { VarCharValue?: string }) => col.VarCharValue ?? "") ?? []
      ) ?? [];

    return { columns, rows, status };
  }

  private async start(sql: string): Promise<string> {
    const command = new StartQueryExecutionCommand({
      QueryString: sql,
      WorkGroup: ATHENA_WORKGROUP,
      ResultConfiguration: {
        OutputLocation: ATHENA_OUTPUT,
      },
    });

    const response = await this.client.send(command);
    if (!response.QueryExecutionId) {
      throw new Error("Failed to start Athena query");
    }

    return response.QueryExecutionId;
  }

  private async waitForCompletion(executionId: string): Promise<QueryExecutionState> {
    for (let attempt = 0; attempt < 20; attempt += 1) {
      const status = await this.client.send(
        new GetQueryExecutionCommand({ QueryExecutionId: executionId })
      );

      const state = status.QueryExecution?.Status?.State ?? QueryExecutionState.FAILED;
      if (state === QueryExecutionState.RUNNING || state === QueryExecutionState.QUEUED) {
        await new Promise((resolve) => setTimeout(resolve, 1_000));
        continue;
      }

      return state;
    }

    return QueryExecutionState.CANCELLED;
  }
}
