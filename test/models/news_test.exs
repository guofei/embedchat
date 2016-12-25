defmodule EmbedChat.NewsTest do
  use EmbedChat.ModelCase

  alias EmbedChat.News

  @valid_attrs %{content_en: "some content", content_ja: "some content", content_zh: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = News.changeset(%News{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = News.changeset(%News{}, @invalid_attrs)
    refute changeset.valid?
  end
end
