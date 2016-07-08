defmodule EmbedChat.UserLogView do
  use EmbedChat.Web, :view
  alias EmbedChat.UserLog

  def render("user_log.json", %{user_log: %UserLog{} = log}) do
    %{
      id: log.id,
      agent: log.agent,
      current_url: log.current_url,
      referrer: log.referrer,
      screen_width: log.screen_width,
      screen_height: log.screen_height,
      language: log.language,
      visit_view: log.visit_view,
      single_page_view: log.single_page_view,
      total_page_view: log.total_page_view,
      location: log.location,
    }
  end
end
