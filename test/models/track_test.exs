defmodule EmbedChat.TrackTest do
  use EmbedChat.ModelCase

  alias EmbedChat.Track

  @valid_attrs %{agent: "some content", current_url: "some content", language: "some content", location: "some content", referrer: "some content", screen_height: 42, screen_width: 42, single_page_view: 42, total_page_view: 42, visit_view: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Track.changeset(%Track{}, @valid_attrs)
    assert changeset.valid?
  end
end
