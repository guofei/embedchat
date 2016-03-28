defmodule EmbedChat.User do
  use EmbedChat.Web, :model

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string, virtual: true
    field :crypted_password, :string

    # user use different pc can have different address
    has_many :addresses, EmbedChat.Address

    has_many :userrooms, EmbedChat.UserRoom
    has_many :rooms, through: [:userrooms, :room]

    timestamps
  end

  def get_name(user) do
    cond do
      user.name ->
        if String.length(user.name) > 0 do
          user.name
        else
          user.email
        end
      true ->
        user.email
    end
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
  def changeset(model, params \\ :empty) do
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
end
