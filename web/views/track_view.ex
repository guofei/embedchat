defmodule EmbedChat.TrackView do
  use EmbedChat.Web, :view

  def render("index.json", %{tracks: tracks}) do
    %{data: render_many(tracks, EmbedChat.TrackView, "track.json")}
  end

  def render("show.json", %{track: track}) do
    %{data: render_one(track, EmbedChat.TrackView, "track.json")}
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
      inserted_at: track.inserted_at}
  end
end
