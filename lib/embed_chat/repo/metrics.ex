defmodule EmbedChat.Repo.Metrics do
  use Elixometer

  def record_metric(entry) do
    update_histogram("query_exec_time", entry.query_time + (entry.queue_time || 0))
    update_histogram("query_queue_time", (entry.queue_time || 0))
    update_spiral("query_count", 1)
  end
end
