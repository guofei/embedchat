defmodule EmbedChat.Attempt do
  use EmbedChatWeb, :model

  schema "attempts" do
    field :email, :string
    field :url, :string

    timestamps()
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:url, :email])
    |> validate_required([:url])
  end
end
