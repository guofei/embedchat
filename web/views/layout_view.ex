defmodule EmbedChat.LayoutView do
  use EmbedChat.Web, :view

  # TODO support params
  def current_locale_path(conn, locale) do
    conn.request_path <> "?locale=#{locale}"
  end
end
