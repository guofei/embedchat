defmodule EmbedChat.MessageMailerTest do
  use EmbedChat.ModelCase

  alias EmbedChat.MessageMailer

  @valid_attrs %{address_uuid: "7488a646-e31f-11e4-aace-600308960662", room_uuid: "7488a646-e31f-11e4-aace-600308960662"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = MessageMailer.changeset(%MessageMailer{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = MessageMailer.changeset(%MessageMailer{}, @invalid_attrs)
    refute changeset.valid?
  end
end
