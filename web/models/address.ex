defmodule EmbedChat.Address do
  use EmbedChat.Web, :model

  schema "addresses" do
    field :uuid, Ecto.UUID
    belongs_to :user, EmbedChat.User
    belongs_to :room, EmbedChat.Room
    has_many :received_messages, EmbedChat.Message, foreign_key: :incoming_id
    has_many :sent_messages, EmbedChat.Message, foreign_key: :outgoing_id

    timestamps
  end

  @required_fields ~w(uuid)
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
