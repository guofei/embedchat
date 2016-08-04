defmodule EmbedChat.User do
  use EmbedChat.Web, :model

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string, virtual: true
    field :crypted_password, :string

    has_many :addresses, EmbedChat.Address
    has_many :userrooms, EmbedChat.UserRoom
    has_many :rooms, through: [:userrooms, :room]

    has_many :auto_message_configs, EmbedChat.AutoMessageConfig

    timestamps
  end

  def registration_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:email, :name, :password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 6)
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :crypted_password, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  def name(user) do
    if user.name && String.length(user.name) > 0 do
      user.name
    else
      user.email
    end
  end

  def latest_for_room(query, room_id, limit \\ 1) do
    from u in query,
      join: um in EmbedChat.UserRoom,
      where: ^room_id == um.room_id,
      order_by: [desc: u.id],
      limit: ^limit
  end
end
