import { useMemo, useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";

import { fetchAlerts, fetchMetrics, runQuery } from "./api";
import AlertsList from "./components/AlertsList";
import KpiGrid from "./components/KpiGrid";
import QueryRunner from "./components/QueryRunner";
import RefreshIndicator from "./components/RefreshIndicator";

function App(): JSX.Element {
  const queryClient = useQueryClient();
  const metricsQuery = useQuery({ queryKey: ["metrics"], queryFn: fetchMetrics, refetchInterval: 2_000 });
  const alertsQuery = useQuery({ queryKey: ["alerts"], queryFn: fetchAlerts, refetchInterval: 5_000 });
  const [querySql, setQuerySql] = useState("SELECT * FROM sample LIMIT 10");
  const [queryResult, setQueryResult] = useState<string[][]>([]);
  const [columns, setColumns] = useState<string[]>([]);
  const [status, setStatus] = useState<string>("");

  const metrics = useMemo(() => metricsQuery.data ?? [], [metricsQuery.data]);
  const alerts = useMemo(() => alertsQuery.data ?? [], [alertsQuery.data]);

  const handleRunQuery = async (sql: string) => {
    const response = await runQuery(sql);
    setQueryResult(response.rows);
    setColumns(response.columns);
    setStatus(response.status);
  };

  const handleRefresh = () => {
    queryClient.invalidateQueries({ queryKey: ["metrics"] });
    queryClient.invalidateQueries({ queryKey: ["alerts"] });
  };

  return (
    <main className="page">
      <header className="page__header">
        <div>
          <h1>DataForge Operations</h1>
          <p>Real-time insights across ingestion, processing, and analytics layers.</p>
        </div>
        <RefreshIndicator isFetching={metricsQuery.isFetching || alertsQuery.isFetching} onRefresh={handleRefresh} />
      </header>
      <section>
        <KpiGrid metrics={metrics} isLoading={metricsQuery.isLoading} />
      </section>
      <section className="layout">
        <AlertsList alerts={alerts} isLoading={alertsQuery.isLoading} />
        <QueryRunner
          sql={querySql}
          onSqlChange={setQuerySql}
          onRun={handleRunQuery}
          rows={queryResult}
          columns={columns}
          status={status}
        />
      </section>
    </main>
  );
}

export default App;
