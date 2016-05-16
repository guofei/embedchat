defmodule EmbedChat.Room do
  use EmbedChat.Web, :model

  schema "rooms" do
    field :uuid, Ecto.UUID

    has_many :messages, EmbedChat.Message
    has_many :auto_message_configs, EmbedChat.AutoMessageConfig
    has_many :userrooms, EmbedChat.UserRoom
    has_many :users, through: [:userrooms, :user]

    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:uuid)
  end
end
