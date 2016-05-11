defmodule EmbedChat.AutoMessageConfig do
  use EmbedChat.Web, :model

  schema "auto_message_configs" do
    field :delay_time, :integer
    field :current_url, :string
    field :referrer, :string
    field :language, :string

    timestamps
  end

  @required_fields ~w(delay_time current_url referrer language)
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
