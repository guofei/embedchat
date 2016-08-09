defmodule EmbedChat.Repo.Metrics do
  use Elixometer

  def record_metric(entry) do
    query_time = System.convert_time_unit(entry.query_time + (entry.queue_time || 0), :native, :microseconds)
    queue_time = System.convert_time_unit(entry.queue_time || 0, :native, :microseconds)
    update_histogram("query_exec_time", query_time)
    update_histogram("query_queue_time", queue_time)
    update_spiral("query_count", 1)
  end
end
