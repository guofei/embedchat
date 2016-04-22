defmodule EmbedChat.LocaleTest do
  use EmbedChat.ConnCase
  alias EmbedChat.Locale

  setup %{conn: conn} = config do
    params =
      case config[:locale] do
        "en" ->
          "?locale=en"
        "ja" ->
          "?locale=ja"
        _ ->
          ""
      end

    conn =
      conn
    |> bypass_through(EmbedChat.Router, :browser)
    |> get("/#{params}")

    {:ok, %{conn: conn}}
  end

  @tag locale: "en"
  test "set en locale by params", %{conn: _} do
    assert Gettext.get_locale(EmbedChat.Gettext) == "en"
  end

  @tag locale: "ja"
  test "set ja locale by params", %{conn: _} do
    assert Gettext.get_locale(EmbedChat.Gettext) == "ja"
  end

  @tag locale: "unknown"
  test "set ohter locale by params", %{conn: _} do
    assert Gettext.get_locale(EmbedChat.Gettext) == "en"
  end

  test "set ja locale by session", %{conn: conn} do
    Locale.call(conn, "ja")
    assert Gettext.get_locale(EmbedChat.Gettext) == "ja"
  end
end
