defmodule EmbedChat.UserProjectTest do
  use EmbedChat.ModelCase

  alias EmbedChat.UserProject

  @valid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UserProject.changeset(%UserProject{}, @valid_attrs)
    assert changeset.valid?
  end
end
