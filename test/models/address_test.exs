defmodule EmbedChat.AddressTest do
  use EmbedChat.ModelCase

  alias EmbedChat.Address

  @valid_attrs %{resource: "some content", uuid: "7488a646-e31f-11e4-aace-600308960662", room_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Address.changeset(%Address{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Address.changeset(%Address{}, @invalid_attrs)
    refute changeset.valid?
  end
end
