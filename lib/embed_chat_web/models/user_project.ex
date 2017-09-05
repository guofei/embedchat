defmodule EmbedChat.UserProject do
  use EmbedChatWeb, :model

  schema "userprojects" do
    belongs_to :user, EmbedChat.User
    belongs_to :project, EmbedChat.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end
