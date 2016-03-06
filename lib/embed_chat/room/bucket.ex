defmodule EmbedChat.Room.Bucket do
  @doc """
  Starts a new bucket.
  """
  def start_link do
    Agent.start_link(fn -> [] end)
  end

  @doc """
  Gets a list from the `bucket`
  """
  def get(bucket) do
    Agent.get(bucket, &(&1))
  end

  @doc """
  Adds the `value` in the `bucket`.
  """
  def add(bucket, value) do
    Agent.update(bucket, &(Enum.uniq [value|&1]))
  end
end
