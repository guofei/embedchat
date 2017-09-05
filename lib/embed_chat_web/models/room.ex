defmodule EmbedChat.Room do
  use EmbedChatWeb, :model

  schema "rooms" do
    field :uuid, Ecto.UUID

    has_many :messages, EmbedChat.Message
    has_many :auto_message_configs, EmbedChat.AutoMessageConfig
    has_many :addresses, EmbedChat.Address, on_delete: :nilify_all
    belongs_to :project, EmbedChat.Project
    has_many :users, through: [:project, :userprojects, :user]

    timestamps()
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(strcut, params \\ %{}) do
    strcut
    |> cast(params, [:uuid, :project_id])
    |> validate_required([:uuid, :project_id])
    |> unique_constraint(:uuid)
  end

  def first(query) do
    from p in query, order_by: [asc: p.id], limit: 1
  end
end
