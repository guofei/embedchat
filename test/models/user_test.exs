defmodule EmbedChat.UserTest do
  use EmbedChat.ModelCase

  alias EmbedChat.User

  @valid_attrs %{password: "some content", email: "some@content.com"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
