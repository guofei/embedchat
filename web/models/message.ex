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

  def for_user(query, user_id) do
    from m in query,
      join: r in EmbedChat.Room, on: m.room_id == r.id,
      join: up in EmbedChat.UserProject, on: up.project_id == r.project_id,
      where: up.user_id == ^user_id and m.type == ^EmbedChat.MessageType.normal(),
      order_by: [desc: :id]
  end

  def visitor_history(query, room_id, address_id, limit) do
    from m in query,
      where: m.room_id == ^room_id and (m.from_id == ^address_id or m.to_id == ^address_id),
      order_by: [desc: :id],
      limit: ^limit
  end

  def visitor_history_except_email_request(query, room_id, address_id, limit) do
    from m in query,
      where: m.room_id == ^room_id and (m.from_id == ^address_id or m.to_id == ^address_id) and m.type != ^EmbedChat.MessageType.email_request,
      order_by: [desc: :id],
      limit: ^limit
  end

  def master_history(query, room_id, address_id, limit) do
    from m in query,
      where: m.room_id == ^room_id and (m.from_id == ^address_id or m.to_id == ^address_id or is_nil(m.to_id)) and m.type != ^EmbedChat.MessageType.email_request,
      order_by: [desc: :id],
      limit: ^limit
  end

  def email_request_count(query, room_id, uuid) do
    from m in query,
      join: a in EmbedChat.Address, on: m.to_id == a.id,
      where: m.room_id == ^room_id and a.uuid == ^uuid and m.type == ^EmbedChat.MessageType.email_request,
      select: count("*")
  end
end
