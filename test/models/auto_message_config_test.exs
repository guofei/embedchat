defmodule EmbedChat.AutoMessageConfigTest do
  use EmbedChat.ModelCase

  alias EmbedChat.AutoMessageConfig

  @valid_attrs %{message: "some message", delay_time: 42, current_url: "some content", language: "some content", referrer: "some content", visit_view: 3, current_url_patttern: "=", language_pattern: "=", referrer_pattern: "=", visit_view_pattern: "="}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = AutoMessageConfig.changeset(%AutoMessageConfig{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = AutoMessageConfig.changeset(%AutoMessageConfig{}, @invalid_attrs)
    refute changeset.valid?
  end
end
