defmodule EmbedChat.Room.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, registry} = EmbedChat.Room.Registry.start_link("test")
    {:ok, registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert EmbedChat.Room.Registry.lookup(registry, "room1") == :error

    EmbedChat.Room.Registry.create(registry, "room1")
    assert {:ok, bucket} = EmbedChat.Room.Registry.lookup(registry, "room1")

    EmbedChat.Room.Bucket.add(bucket, 1)
    assert EmbedChat.Room.Bucket.get(bucket) == [1]
  end

  test "removes buckets on exit", %{registry: registry} do
    EmbedChat.Room.Registry.create(registry, "shopping")
    {:ok, bucket} = EmbedChat.Room.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)
    assert EmbedChat.Room.Registry.lookup(registry, "shopping") == :error
  end
end
