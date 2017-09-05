defmodule EmbedChatWeb.TrackView do
  use EmbedChatWeb, :view

  def render("index.json", %{tracks: tracks}) do
    %{data: render_many(tracks, EmbedChatWeb.TrackView, "track.json")}
  end

  def render("show.json", %{track: track}) do
    %{data: render_one(track, EmbedChatWeb.TrackView, "track.json")}
  end

  def render("track.json", %{track: track}) do
    %{id: track.id,
      agent: track.agent,
      current_url: track.current_url,
      referrer: track.referrer,
      screen_width: track.screen_width,
      screen_height: track.screen_height,
      language: track.language,
      visit_view: track.visit_view,
      single_page_view: track.single_page_view,
      total_page_view: track.total_page_view,
      location: track.location,
      address_id: track.address_id,
      ip: track.ip,
      inserted_at: track.inserted_at}
  end
end
