defmodule EmbedChat.AttemptTest do
  use EmbedChat.ModelCase

  alias EmbedChat.Attempt

  @valid_attrs %{email: "some content", url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Attempt.changeset(%Attempt{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Attempt.changeset(%Attempt{}, @invalid_attrs)
    refute changeset.valid?
  end
end
