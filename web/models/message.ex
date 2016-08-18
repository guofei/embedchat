defmodule EmbedChat.Message do
  use EmbedChat.Web, :model

  schema "messages" do
    field :body, :string
    field :type, :string
    belongs_to :from, EmbedChat.Address
    belongs_to :to, EmbedChat.Address
    belongs_to :room, EmbedChat.Room
    has_one :from_visitor, through: [:from, :visitor]
    has_one :to_visitor, through: [:to, :visitor]
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
    |> cast(params, [:body, :from_id, :to_id, :type])
    |> validate_required([:body])
  end

  def preload_for_user_and_visitor(query, user_id) do
    from m in query,
      join: um in EmbedChat.UserRoom, on: m.room_id == um.room_id,
      where: um.user_id == ^user_id and m.type == ^EmbedChat.MessageType.normal(),
      preload: [:from, :to, :from_user, :to_user, :from_visitor, :to_visitor],
      order_by: [desc: :inserted_at]
  end

  def preload_for_room_and_address(query, room_id, address_id, limit) do
    from m in query,
      where: m.room_id == ^(room_id) and (m.from_id == ^(address_id) or m.to_id == ^(address_id)),
      preload: [:from, :to, :from_user],
      order_by: [desc: :inserted_at],
      limit: ^limit
  end

  def preload_for_room_and_address_except_email_request(query, room_id, address_id, limit) do
    from m in query,
      where: m.room_id == ^(room_id) and (m.from_id == ^(address_id) or m.to_id == ^(address_id)) and m.type != ^EmbedChat.MessageType.email_request,
      preload: [:from, :to, :from_user],
      order_by: [desc: :inserted_at],
      limit: ^limit
  end

  def email_request_count(query, room_id, uuid) do
    from m in query,
      join: a in EmbedChat.Address, on: m.to_id == a.id,
      where: m.room_id == ^room_id and a.uuid == ^uuid and m.type == ^EmbedChat.MessageType.email_request,
      select: count("*")
  end
end
