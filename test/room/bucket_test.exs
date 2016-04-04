defmodule EmbedChat.Room.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = EmbedChat.Room.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "stores values", %{bucket: bucket} do
    assert EmbedChat.Room.Bucket.map(bucket) == %{}

    EmbedChat.Room.Bucket.put(bucket, 1, "1")
    assert EmbedChat.Room.Bucket.map(bucket) == %{1 => "1"}

    EmbedChat.Room.Bucket.put(bucket, 2, "2")
    assert EmbedChat.Room.Bucket.map(bucket) == %{1 => "1", 2 => "2"}

    EmbedChat.Room.Bucket.delete(bucket, 1)
    assert EmbedChat.Room.Bucket.map(bucket) == %{2 => "2"}
  end
end
