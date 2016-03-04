defmodule EmbedChat.Room.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = EmbedChat.Room.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "stores values", %{bucket: bucket} do
    assert EmbedChat.Room.Bucket.get(bucket) == []

    EmbedChat.Room.Bucket.add(bucket, 1)
    assert EmbedChat.Room.Bucket.get(bucket) == [1]

    EmbedChat.Room.Bucket.add(bucket, 2)
    assert EmbedChat.Room.Bucket.get(bucket) == [2, 1]
  end
end
