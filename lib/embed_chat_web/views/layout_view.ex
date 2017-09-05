defmodule EmbedChatWeb.LayoutView do
  use EmbedChatWeb, :view

  # TODO support params
  def current_locale_path(conn, locale) do
    conn.request_path <> "?locale=#{locale}"
  end

  # TODO support params
  def current_locale_url(conn, locale) do
    EmbedChatWeb.Router.Helpers.url(conn) <> conn.request_path <> "?locale=#{locale}"
  end
end
