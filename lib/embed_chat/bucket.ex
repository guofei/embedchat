defmodule EmbedChat.Bucket do
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
    Agent.get(bucket, fn list -> list end)
  end

  @doc """
  Adds the `value` in the `bucket`.
  """
  def add(bucket, value) do
    Agent.update(bucket, fn list -> [value|list] end)
  end
end
