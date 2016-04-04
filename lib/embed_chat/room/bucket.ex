defmodule EmbedChat.Room.Bucket do
  @doc """
  Starts a new bucket.
  """
  def start_link do
    Agent.start_link(fn -> MapSet.new() end)
  end

  @doc """
  Gets a list from the `bucket`
  """
  def get(bucket) do
    Agent.get(bucket, &(MapSet.to_list(&1)))
  end

  @doc """
  Adds the `value` in the `bucket`.
  """
  def add(bucket, value) do
    Agent.update(bucket, &(MapSet.put(&1, value)))
  end

  @doc """
  Deletes the `value` in the `bucket`.
  """
  def delete(bucket, value) do
    Agent.update(bucket, &(MapSet.delete &1, value))
  end
end
