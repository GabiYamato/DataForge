import type { ChangeEvent, FormEvent } from "react";

interface Props {
  sql: string;
  onSqlChange: (sql: string) => void;
  onRun: (sql: string) => Promise<void>;
  rows: string[][];
  columns: string[];
  status: string;
}

function QueryRunner({ sql, onSqlChange, onRun, rows, columns, status }: Props) {
  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    await onRun(sql);
  };

  return (
    <article className="card card--wide">
      <header className="card__header">
        <h2>Ad-hoc Query</h2>
        <span className="card__badge">{status}</span>
      </header>
      <form onSubmit={handleSubmit} className="query-runner__form">
  <textarea value={sql} onChange={(event: ChangeEvent<HTMLTextAreaElement>) => onSqlChange(event.target.value)} rows={6} />
        <button type="submit">Run</button>
      </form>
      <div className="query-runner__table-wrapper">
        <table>
          <thead>
            <tr>
              {columns.map((column) => (
                <th key={column}>{column}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((row, index) => (
              <tr key={index}>
                {row.map((value, columnIndex) => (
                  <td key={columnIndex}>{value}</td>
                ))}
              </tr>
            ))}
            {rows.length === 0 && (
              <tr>
                <td colSpan={columns.length || 1}>No results.</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </article>
  );
}

export default QueryRunner;
