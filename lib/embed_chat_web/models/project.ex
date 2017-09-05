defmodule EmbedChat.Project do
  use EmbedChatWeb, :model

  schema "projects" do
    field :domain, :string
    field :name, :string
    has_one :room, EmbedChat.Room
    has_many :userprojects, EmbedChat.UserProject
    has_many :users, through: [:userprojects, :user]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:domain, :name])
    |> validate_required([:domain, :name])
  end
end
