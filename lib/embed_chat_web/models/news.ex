defmodule EmbedChat.News do
  use EmbedChatWeb, :model

  schema "news" do
    field :content_en, :string
    field :content_ja, :string
    field :content_zh, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content_en, :content_ja, :content_zh])
    |> validate_required([:content_en])
  end
end
