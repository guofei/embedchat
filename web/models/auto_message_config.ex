defmodule EmbedChat.AutoMessageConfig do
  use EmbedChat.Web, :model

  schema "auto_message_configs" do
    field :delay_time, :integer
    field :message, :string
    field :current_url, :string
    field :referrer, :string
    field :language, :string
    field :visit_view, :integer
    field :single_page_view, :integer
    field :total_page_view, :integer
    field :current_url_pattern, :string, default: "include"
    field :referrer_pattern, :string, default: "include"
    field :language_pattern, :string, default: "="
    field :visit_view_pattern, :string, default: "="
    field :single_page_view_pattern, :string, default: "="
    field :total_page_view_pattern, :string, default: "="
    belongs_to :user, EmbedChat.User
    belongs_to :room, EmbedChat.Room

    timestamps
  end

  @required_fields ~w(message room_id)
  @optional_fields ~w(delay_time referrer language visit_view current_url_pattern referrer_pattern language_pattern visit_view_pattern current_url single_page_view single_page_view_pattern total_page_view total_page_view_pattern)

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

  def match(models,  %{"href" => cur, "language" => lan, "referrer" => ref, "visitView" => vv, "singlePageView" => spv, "totalPageView" => tpv}) do
    status = %{current_url: cur, referrer: ref, language: lan, visit_view: vv, single_page_view: spv, total_page_view: tpv}
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
    %{model: m, status: s} = filter(%{model: model, status: status})
    do_match(m.current_url_pattern, strip_url(m.current_url), strip_url(s.current_url)) and
    do_match(m.referrer_pattern, strip_url(m.referrer), strip_url(s.referrer)) and
    do_match(m.language_pattern, language(m.language), language(s.language)) and
    do_match(m.visit_view_pattern, m.visit_view, s.visit_view) and
    do_match(m.single_page_view_pattern, m.single_page_view, s.single_page_view) and
    do_match(m.total_page_view_pattern, m.total_page_view, s.total_page_view)
  end

  defp should_strip_current_url?(model, status) do
    with true <- model.current_url_pattern != "regex",
         true <- model.current_url && status.current_url,
      do: !String.match?(model.current_url, ~r/^http/) or !String.match?(status.current_url, ~r/^http/)
  end

  defp should_strip_referrer?(model, status) do
    with true <- model.referrer_pattern != "regex",
         true <- model.referrer && status.referrer,
      do: !String.match?(model.referrer, ~r/^http/) or !String.match?(status.referrer, ~r/^http/)
  end

  defp filter(%{model: model, status: status}) do
    case should_strip_current_url?(model, status) do
      true ->
        case should_strip_referrer?(model, status) do
          true ->
            m = %{model | current_url: strip_url(model.current_url), referrer: strip_url(model.referrer)}
            s = %{status | current_url: strip_url(status.current_url), referrer: strip_url(status.referrer)}
            %{model: m, status: s}
          _ ->
            m = %{model | current_url: strip_url(model.current_url)}
            s = %{status | current_url: strip_url(status.current_url)}
            %{model: m, status: s}
        end
      _ ->
        case should_strip_referrer?(model, status) do
          true ->
            m = %{model | referrer: strip_url(model.referrer)}
            s = %{status | referrer: strip_url(status.referrer)}
            %{model: m, status: s}
          _ ->
            %{model: model, status: status}
        end
    end
  end

  defp language(str) when is_binary(str) do
    str
    |> String.downcase
    |> String.slice(0..1)
  end
  defp language(arg), do: arg

  defp strip_url(url) when is_binary(url) do
    url
    |> String.rstrip(?/)
    |> String.replace(~r/^https?:\/\//, "")
  end
  defp strip_url(url), do: url

  # ignore nil and empty pattern
  defp do_match(p, v1, v2) when is_nil(p) or is_nil(v1) or is_nil(v2) or p == "" or v1 == "" or v2 == "", do: true

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
