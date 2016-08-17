defmodule EmbedChat.VisitorTest do
  use EmbedChat.ModelCase

  alias EmbedChat.Visitor

  @valid_attrs %{email: "some@domain.com", name: "some content", note: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Visitor.changeset(%Visitor{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Visitor.changeset(%Visitor{}, @invalid_attrs)
    refute changeset.valid?
  end
end
