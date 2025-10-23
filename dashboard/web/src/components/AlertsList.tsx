import type { Alert } from "../api";

interface Props {
  alerts: Alert[];
  isLoading: boolean;
}

function AlertsList({ alerts, isLoading }: Props) {
  return (
    <article className="card">
      <header className="card__header">
        <h2>Alerts</h2>
        {isLoading && <span className="card__badge">Loading</span>}
      </header>
      <ul className="alerts">
        {alerts.map((alert) => (
          <li key={alert.id} className={`alerts__item alerts__item--${alert.severity}`}>
            <div>
              <p className="alerts__message">{alert.message}</p>
              <p className="alerts__meta">
                <span>{alert.source}</span>
                <span>{new Date(alert.timestamp).toLocaleTimeString()}</span>
              </p>
            </div>
          </li>
        ))}
        {alerts.length === 0 && !isLoading && <li>No recent alerts.</li>}
      </ul>
    </article>
  );
}

export default AlertsList;
