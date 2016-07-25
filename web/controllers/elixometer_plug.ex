defmodule ElixometerPlug do
  @behaviour Plug
  import Plug.Conn, only: [register_before_send: 2]
  use Elixometer

  def init(opts), do: opts

  def call(conn, _config) do
    req_start_time = :os.timestamp

    register_before_send conn, fn conn ->
      # increment count
      update_spiral("resp_count", 1)

      # log response time in milliseconds
      req_end_time = :os.timestamp
      duration = :timer.now_diff(req_end_time, req_start_time) / 1000
      update_histogram("resp_time", duration)

      conn
    end
  end
end
