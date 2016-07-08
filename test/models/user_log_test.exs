defmodule EmbedChat.UserLogTest do
  use EmbedChat.ModelCase

  alias EmbedChat.UserLog

  @valid_attrs %{agent: "some content", href: "some content", language: "some content", location: "some content", referrer: "some content", screen_height: "some content", screen_width: "some content", single_page_view: "some content", total_page_view: "some content", visit_view: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UserLog.changeset(%UserLog{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = UserLog.changeset(%UserLog{}, @invalid_attrs)
    refute changeset.valid?
  end
end
