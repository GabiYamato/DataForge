import type { MetricPoint } from "../api";

interface Props {
  metrics: MetricPoint[];
  isLoading: boolean;
}

function KpiGrid({ metrics, isLoading }: Props) {
  return (
    <div className="kpi-grid">
      {metrics.map((metric) => (
        <div key={metric.kpi} className="kpi">
          <span className="kpi__label">{metric.kpi}</span>
          <span className="kpi__value">
            {metric.value.toLocaleString(undefined, { maximumFractionDigits: 2 })}
            {metric.unit ? ` ${metric.unit}` : ""}
          </span>
          <span className="kpi__timestamp">{new Date(metric.timestamp).toLocaleTimeString()}</span>
        </div>
      ))}
      {metrics.length === 0 && !isLoading && <p>No metrics available.</p>}
      {isLoading && <p>Loading metrics...</p>}
    </div>
  );
}

export default KpiGrid;
