defmodule EmbedChat.User do
  use EmbedChatWeb, :model

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string, virtual: true
    field :crypted_password, :string

    has_many :addresses, EmbedChat.Address
    has_many :userprojects, EmbedChat.UserProject
    has_many :projects, through: [:userprojects, :project]
    has_many :rooms, through: [:projects, :room]

    has_many :auto_message_configs, EmbedChat.AutoMessageConfig

    timestamps()
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
    |> cast(params, [:email, :name])
    |> validate_required([:email, :name])
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:email, min: 1, max: 50)
    |> validate_length(:name, min: 1, max: 20)
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

  def admin?(struct) do
    if struct.id == 1 do
      true
    else
      false
    end
  end

  def sorted(query) do
    from p in query, order_by: [desc: p.id]
  end

  def latest_for_room(query, room, limit \\ 1) do
    from u in query,
      join: up in EmbedChat.UserProject, on: u.id == up.user_id,
      where: ^room.project_id == up.project_id,
      order_by: [desc: u.id],
      limit: ^limit
  end
end
