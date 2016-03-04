defmodule EmbedChat.Room.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    {:ok, registry} = EmbedChat.Room.Registry.start_link(context.test)
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
    EmbedChat.Room.Registry.create(registry, "room1")
    {:ok, bucket} = EmbedChat.Room.Registry.lookup(registry, "room1")
    Agent.stop(bucket)
    assert EmbedChat.Room.Registry.lookup(registry, "room1") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    EmbedChat.Room.Registry.create(registry, "room1")
    {:ok, bucket} = EmbedChat.Room.Registry.lookup(registry, "room1")

    # Stop the bucket with non-normal reason
    Process.exit(bucket, :shutdown)

    # Wait until the bucket is dead
    ref = Process.monitor(bucket)
    assert_receive {:DOWN, ^ref, _, _, _}

    assert EmbedChat.Room.Registry.lookup(registry, "room1") == :error
  end
end
