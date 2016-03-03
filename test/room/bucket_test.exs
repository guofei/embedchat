defmodule EmbedChat.Room.BucketTest do
  use ExUnit.Case, async: true

  test "stores values by key" do
    {:ok, bucket} = EmbedChat.Room.Bucket.start_link
    assert EmbedChat.Room.Bucket.get(bucket) == nil

    EmbedChat.Room.Bucket.add(bucket, 1)
    assert EmbedChat.Room.Bucket.get(bucket) == 1
  end
end
