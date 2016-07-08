defmodule EmbedChat.UserLog do
  use EmbedChat.Web, :model

  schema "user_logs" do
    field :agent, :string
    field :href, :string
    field :referrer, :string
    field :screen_width, :string
    field :screen_height, :string
    field :language, :string
    field :visit_view, :string
    field :single_page_view, :string
    field :total_page_view, :string
    field :location, :string
    belongs_to :address, EmbedChat.Address

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:agent, :href, :referrer, :screen_width, :screen_height, :language, :visit_view, :single_page_view, :total_page_view, :location])
    |> validate_required([:agent, :href, :referrer, :screen_width, :screen_height, :language, :visit_view, :single_page_view, :total_page_view, :location])
  end
end
