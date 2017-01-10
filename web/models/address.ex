defmodule EmbedChat.Address do
  use EmbedChat.Web, :model

  schema "addresses" do
    field :uuid, Ecto.UUID
    belongs_to :user, EmbedChat.User
    belongs_to :visitor, EmbedChat.Visitor
    belongs_to :room, EmbedChat.Room
    has_many :outgoing_messages, EmbedChat.Message, foreign_key: :from_id
    has_many :incoming_messages, EmbedChat.Message, foreign_key: :to_id
    has_many :tracks, EmbedChat.Track

    timestamps()
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:uuid, :room_id, :visitor_id, :user_id])
    |> validate_required([:uuid, :room_id])
    |> foreign_key_constraint(:room_id)
    |> foreign_key_constraint(:visitor_id)
  end

  def latest_for_room_master(query, user_id, room_id) do
    from a in query,
      where: a.user_id == ^user_id and a.room_id == ^room_id,
      order_by: [desc: a.updated_at],
      limit: 1
  end

  def get_by_master(query, user_id, address_id) do
    from a in query,
      join: r in EmbedChat.Room, on: r.id == a.room_id,
      join: up in EmbedChat.UserProject, on: r.project_id == up.project_id and up.user_id == ^user_id,
      where: a.id == ^address_id,
      preload: :visitor
  end

  defp for_room(query, room_id) do
    from a in query,
      where: ^room_id == a.room_id,
      order_by: [desc: a.updated_at]
  end

  def for_room_with_visitors(query, room_id) do
    query
    |> for_room(room_id)
    |> Ecto.Query.where([address], is_nil(address.user_id))
    |> Ecto.Query.preload(:visitor)
  end

  def latest_for_room(query, room_id, limit) do
    query |> for_room(room_id) |> Ecto.Query.limit(^limit)
  end

  def where_in(query, room_id, ids) when is_list(ids) do
    from a in query,
      where: a.id in ^ids and a.room_id == ^room_id
  end

  def latest_for_room(query, room_id) do
    latest_for_room(query, room_id, 1)
  end

  def latest_for_room_with_logs(query, room_id, limit) do
    query
    |> latest_for_room(room_id, limit)
    |> Ecto.Query.preload(:tracks)
  end

  def with_visitor(query, room_uuid, uuid) do
    from a in query,
      join: r in EmbedChat.Room, on: r.uuid == ^room_uuid and r.id == a.room_id,
      where: a.uuid == ^uuid,
      preload: :visitor
  end

  def visitor_count(query, room_id, uuid) do
    from a in query,
      where: a.room_id == ^room_id and a.uuid == ^uuid and a.visitor_id > 0,
      select: count("*")
  end
end
