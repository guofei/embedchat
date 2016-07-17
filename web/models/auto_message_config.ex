defmodule EmbedChat.AutoMessageConfig do
  use EmbedChat.Web, :model
  alias EmbedChat.UserLog

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

  @required_fields ~w(message room_id)a
  @all_fields ~w(message room_id delay_time referrer language visit_view current_url_pattern referrer_pattern language_pattern visit_view_pattern current_url single_page_view single_page_view_pattern total_page_view total_page_view_pattern)a

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:room_id)
  end

  # current_status = %{current_url: url, referrer: referrer, language: lan, visit_view: n}
  def match(models, %UserLog{} = status) when is_list(models) do
    Enum.filter(models, fn(model) -> match(model, status) end)
  end

  def match(models, _status) when is_nil(models) do
    []
  end

  def match(m, s) do
    do_match_url(m.current_url_pattern, m.current_url, s.current_url) and
    do_match_url(m.referrer_pattern, m.referrer, s.referrer) and
    do_match(m.language_pattern, language(m.language), language(s.language)) and
    do_match(m.visit_view_pattern, m.visit_view, s.visit_view) and
    do_match(m.single_page_view_pattern, m.single_page_view, s.single_page_view) and
    do_match(m.total_page_view_pattern, m.total_page_view, s.total_page_view)
  end

  defp language(str) when is_binary(str) do
    str
    |> String.downcase
    |> String.slice(0..1)
  end
  defp language(arg), do: arg

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

  # ignore nil and empty pattern
  defp do_match_url(p, v1, v2) when is_nil(p) or is_nil(v1) or is_nil(v2) or p == "" or v1 == "" or v2 == "" do
    do_match(p, v1, v2)
  end
  # ignore regex
  defp do_match_url("regex", v1, v2), do: do_match("regex", v1, v2)

  defp do_match_url(pattern, url_pattern, current_url) do
    case should_strip_url_end_slash?(pattern, url_pattern, current_url) do
      true ->
        case should_strip_url_scheme?(pattern, url_pattern, current_url) do
          true ->
            url_pattern =
              url_pattern
              |> String.rstrip(?/)
              |> String.replace(~r/^https?:\/\//, "")
            current_url =
              current_url
              |> String.rstrip(?/)
              |> String.replace(~r/^https?:\/\//, "")
            do_match(pattern, url_pattern, current_url)
          _ ->
            url_pattern =
              url_pattern
              |> String.rstrip(?/)
            current_url =
              current_url
              |> String.rstrip(?/)
            do_match(pattern, url_pattern, current_url)
        end
      _ ->
        do_match(pattern, url_pattern, current_url)
    end
  end

  defp should_strip_url_end_slash?(url_pattern, url1, url2) do
    if url_pattern != "regex" && url1 && url2, do: true, else: false
  end

  defp should_strip_url_scheme?(pattern, url1, url2) do
    should_strip_url_end_slash?(pattern, url1, url2) &&
      !(String.match?(url1, ~r/^http/) && String.match?(url2, ~r/^http/))
  end
end
