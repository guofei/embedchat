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

  @required_fields ~w(email password name)
  @optional_fields ~w(name)

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password), [])
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
    |> cast(params, @required_fields, @optional_fields)
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
end
