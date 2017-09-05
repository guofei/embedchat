defmodule EmbedChatWeb.Locale do
  import Plug.Conn

  def init(_default), do: nil

  def call(conn, default) do
    case extract_param_locale(conn) do
      nil ->
        locale = List.first(extract_locale(conn)) || default
        set_locale conn, locale
      locale ->
        set_locale conn, locale
    end
  end

  defp set_locale(conn, locale) when is_nil(locale) do
    conn
  end

  defp set_locale(conn, locale) do
    text_locale = List.first(String.split(locale, "-"))
    Gettext.put_locale(EmbedChatWeb.Gettext, text_locale)
    conn |> put_session(:locale, locale)
  end

  defp extract_param_locale(conn) do
    case conn.params["locale"] do
      nil ->
        case get_session(conn, :locale) do
          nil ->
            nil
          locale ->
            locale_check locale
        end
      locale ->
        locale_check locale
    end
  end

  defp locale_check(locale) do
    if Enum.member?(EmbedChatWeb.Gettext.supported_locales, locale) do
      locale
    else
      nil
    end
  end

  defp extract_locale(conn) do
    # Filter for only known locales
    conn
    |> extract_accept_language
    |> Enum.filter(fn locale -> in_supported_locales?(EmbedChatWeb.Gettext.supported_locales, locale) end)
  end

  defp in_supported_locales?(locales, locale) when is_binary(locale) do
    locales
    |> Enum.map(&String.downcase/1)
    |> Enum.member?(String.downcase(List.first(String.split(locale, "-"))))
  end

  defp in_supported_locales?(_, _) do
    false
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
