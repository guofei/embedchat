defmodule EmbedChat.UserRoom do
  use EmbedChat.Web, :model

  schema "userrooms" do
    belongs_to :user, EmbedChat.User
    belongs_to :room, EmbedChat.Room

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
  end
end
