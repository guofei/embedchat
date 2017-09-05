defmodule EmbedChat.Track do
  use EmbedChatWeb, :model

  schema "tracks" do
    field :agent, :string
    field :current_url, :string
    field :referrer, :string
    field :screen_width, :integer
    field :screen_height, :integer
    field :language, :string
    field :visit_view, :integer
    field :single_page_view, :integer
    field :total_page_view, :integer
    field :location, :string
    field :ip, :string
    belongs_to :address, EmbedChat.Address

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:agent, :current_url, :referrer, :screen_width, :screen_height, :language, :visit_view, :single_page_view, :total_page_view, :location])
  end

  def for_address_id(query, address_id, limit) do
    from log in query,
      order_by: [desc: :id],
      where: log.address_id == ^address_id,
      limit: ^limit
  end
end
