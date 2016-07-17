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

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(strcut, params \\ %{}) do
    strcut
    |> cast(params, [:uuid])
    |> unique_constraint(:uuid)
  end

  def first(query) do
    from p in query, order_by: [asc: p.id], limit: 1
  end
end
