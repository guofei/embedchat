defmodule EmbedChat.Locale do
  import Plug.Conn

  def init(_default), do: nil

  def call(conn, default) do
    case conn.params["locale"] || get_session(conn, :locale) do
      nil     ->
        locale = List.first(extract_locale(conn)) || default
        Gettext.put_locale(EmbedChat.Gettext, locale)
        conn |> put_session(:locale, locale)
      locale  ->
        Gettext.put_locale(EmbedChat.Gettext, locale)
        conn |> put_session(:locale, locale)
    end
  end

  defp extract_locale(conn) do
    if Blank.present? conn.params["locale"] do
      [conn.params["locale"] | extract_accept_language(conn)]
    else
      extract_accept_language(conn)
    end
    # Filter for only known locales
    |> Enum.filter(fn locale -> Enum.member?(EmbedChat.Gettext.supported_locales, locale) end)
  end

  defp extract_accept_language(conn) do
    case conn |> get_req_header("accept-language") do
      [value|_] ->
        value
        |> String.split(",")
        |> Enum.map(&parse_language_option/1)
        |> Enum.sort(&(&1.quality > &2.quality))
        |> Enum.map(&(&1.tag))
      _ ->
        []
    end
  end

  defp parse_language_option(string) do
    captures = ~r/^(?<tag>[\w\-]+)(?:;q=(?<quality>[\d\.]+))?$/i
    |> Regex.named_captures(string)

    quality = case Float.parse(captures["quality"] || "1.0") do
                {val, _} -> val
                _ -> 1.0
              end

    %{tag: captures["tag"], quality: quality}
  end
end
