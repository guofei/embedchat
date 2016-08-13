defmodule EmbedChat.Visitor do
  use EmbedChat.Web, :model

  schema "visitors" do
    field :name, :string
    field :email, :string
    field :note, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :note])
    |> validate_required([:name, :email, :note])
  end
end
