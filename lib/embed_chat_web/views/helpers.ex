defmodule EmbedChatWeb.ViewHelpers do
  # admin
  def admin_logged_in?(conn), do: Guardian.Plug.authenticated?(conn, :admin)
  def admin_user(conn), do: Guardian.Plug.current_resource(conn, :admin)

  # user
  def logged_in?(conn), do: Guardian.Plug.authenticated?(conn)
  def current_user(conn), do: Guardian.Plug.current_resource(conn)

  # TODO upgrade elixir to 1.4
  # change naive_datetime to datetime
  def utc_datetime(naive_datetime) do
  end
end
