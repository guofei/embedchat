defmodule EmbedChat.AutoMessageConfig do
  use EmbedChat.Web, :model

  schema "auto_message_configs" do
    field :delay_time, :integer
    field :message, :string
    field :current_url, :string
    field :referrer, :string
    field :language, :string
    field :visit_view, :integer
    field :current_url_pattern, :string
    field :referrer_pattern, :string
    field :language_pattern, :string
    field :visit_view_pattern, :integer
    belongs_to :user, EmbedChat.User

    timestamps
  end

  @required_fields ~w(message delay_time current_url referrer language visit_view)
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

  # current_status = %{current_url: url, referrer: referrer, language: lang, visit_view: n}
  def match(models, status) when is_list(models) do
    Enum.filter(models, fn(model) -> match(model, status) end)
  end

  def match(models, status) when is_nil(models) do
    []
  end

  def match(model, status) do
    match(model.current_url_pattern, model.current_url, status.current_url) and
    match(model.referrer_pattern, model.referrer, status.referrer) and
    match(model.language_pattern, model.language, status.language) and
    match(model.visit_view_pattern, model.visit_view, status.visit_view)
  end

  defp match(_, v1, v2) when is_nil(v1) or is_nil(v2) do
    true
  end

  defp match("", v1, v2) do
    true
  end

  defp match("=", v1, v2) do
    v1 == v2
  end

  defp match("!=", v1, v2) do
    v1 != v2
  end

  defp match(">", v1, v2) do
    v1 > v2
  end

  defp match("<", v1, v2) do
    v1 < v2
  end

  defp match(">=", v1, v2) do
    v1 >= v2
  end

  defp match("<=", v1, v2) do
    v1 <= v2
  end
  # user match
  # if {:ok, config} = match(models, current_status) do
  #   send(config.message)
  # end
end
