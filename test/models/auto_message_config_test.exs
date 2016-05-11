defmodule EmbedChat.AutoMessageConfigTest do
  use EmbedChat.ModelCase

  alias EmbedChat.AutoMessageConfig

  @valid_attrs %{current_url: "some content", delay_time: 42, language: "some content", referrer: "some content"}
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
