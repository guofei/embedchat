defmodule EmbedChat.Room.Bucket do
  @doc """
  Starts a new bucket.
  """
  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a list from the `bucket`
  """
  def map(bucket) do
    Agent.get(bucket, &(&1))
  end

  @doc """
  Adds the `value` in the `bucket`.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &(Map.put &1, key, value))
  end

  @doc """
  Deletes the `value` in the `bucket`.
  """
  def delete(bucket, key) do
    Agent.update(bucket, &(Map.delete &1, key))
  end
end
