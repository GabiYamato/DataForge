interface Props {
  isFetching: boolean;
  onRefresh: () => void;
}

function RefreshIndicator({ isFetching, onRefresh }: Props) {
  return (
    <div className="refresh">
      <button type="button" onClick={onRefresh} disabled={isFetching}>
        {isFetching ? "Refreshing..." : "Refresh"}
      </button>
    </div>
  );
}

export default RefreshIndicator;
