defmodule EmbedChat.MessageMailer do
  use EmbedChat.Web, :model

  embedded_schema do
    field :address_uuid, Ecto.UUID
    field :room_uuid, Ecto.UUID
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:address_uuid, :room_uuid])
    |> validate_required([:address_uuid, :room_uuid])
  end
end
