defmodule EmbedChat.Message do
  use EmbedChat.Web, :model

  schema "messages" do
    field :body, :string
    belongs_to :from, EmbedChat.Address
    belongs_to :to, EmbedChat.Address
    belongs_to :room, EmbedChat.Room
    has_one :from_user, through: [:from, :user]
    has_one :to_user, through: [:to, :user]

    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body, :from_id, :to_id])
    |> validate_required([:body])
  end

  def preload_for_user(query, user_id) do
    from m in query,
      join: um in EmbedChat.UserRoom, on: m.room_id == um.room_id,
      where: um.user_id == ^user_id,
      preload: [:from, :to, :from_user, :to_user],
      order_by: [desc: :inserted_at]
  end

  def preload_for_room_and_address(query, room_id, address_id, limit) do
    from m in query,
      where: m.room_id == ^(room_id) and (m.from_id == ^(address_id) or m.to_id == ^(address_id)),
      preload: [:from, :to, :from_user],
      order_by: [desc: :inserted_at],
      limit: ^limit
  end
end
