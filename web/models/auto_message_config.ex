defmodule EmbedChat.AutoMessageConfig do
  use EmbedChat.Web, :model

  schema "auto_message_configs" do
    field :delay_time, :integer
    field :message, :string
    field :current_url, :string
    field :referrer, :string
    field :language, :string
    field :visit_view, :integer
    field :current_url_pattern, :string, default: "include"
    field :referrer_pattern, :string, default: "include"
    field :language_pattern, :string, default: "="
    field :visit_view_pattern, :string, default: "="
    belongs_to :user, EmbedChat.User
    belongs_to :room, EmbedChat.Room

    timestamps
  end

  @required_fields ~w(message room_id)
  @optional_fields ~w(delay_time referrer language visit_view current_url_pattern referrer_pattern language_pattern visit_view_pattern current_url)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:room_id)
  end

  def match(models,  %{"href" => cur, "language" => lan, "referrer" => ref, "visitView" => vv}) do
    status = %{current_url: cur, referrer: ref, language: lan, visit_view: vv}
    match(models, status)
  end

  # current_status = %{current_url: url, referrer: referrer, language: lan, visit_view: n}
  def match(models, status) when is_list(models) do
    Enum.filter(models, fn(model) -> match(model, status) end)
  end

  def match(models, _status) when is_nil(models) do
    []
  end

  def match(model, status) do
    do_match(model.current_url_pattern, model.current_url, status.current_url) and
    do_match(model.referrer_pattern, model.referrer, status.referrer) and
    do_match(model.language_pattern, model.language, status.language) and
    do_match(model.visit_view_pattern, model.visit_view, status.visit_view)
  end

  # ignore nil and empty pattern
  defp do_match(_, v1, v2) when is_nil(v1) or is_nil(v2), do: true
  defp do_match(_, "", _), do: true
  defp do_match(_, _, ""), do: true
  defp do_match("", _, _), do: true

  defp do_match("~=", regex, str), do: do_match_regex(regex, str)
  defp do_match("regex", regex, str), do: do_match_regex(regex, str)
  defp do_match("include", short, long), do: do_match_regex(short, long)
  defp do_match("=", pattern, status), do: pattern == status
  defp do_match("!=", pattern, status), do: pattern != status
  defp do_match(">", pattern, status), do: status > pattern
  defp do_match("<", pattern, status), do: status < pattern
  defp do_match(">=", pattern, status), do: status >= pattern
  defp do_match("<=", pattern, status), do: status <= pattern

  # ignore all pattern
  defp do_match(_, _, _), do: false

  defp do_match_regex(regex, str) do
    case Regex.compile(regex) do
      {:ok, r} ->
        Regex.match?(r, str)
      _ ->
        false
    end
  end
end
