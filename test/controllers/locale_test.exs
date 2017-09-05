defmodule EmbedChatWeb.LocaleTest do
  use EmbedChatWeb.ConnCase
  alias EmbedChatWeb.Locale

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
    |> bypass_through(EmbedChatWeb.Router, :browser)
    |> get("/#{params}")

    {:ok, %{conn: conn}}
  end

  @tag locale: "en"
  test "set en locale by params", %{conn: _} do
    assert Gettext.get_locale(EmbedChatWeb.Gettext) == "en"
  end

  @tag locale: "ja"
  test "set ja locale by params", %{conn: _} do
    assert Gettext.get_locale(EmbedChatWeb.Gettext) == "ja"
  end

  @tag locale: "unknown"
  test "set ohter locale by params", %{conn: _} do
    assert Gettext.get_locale(EmbedChatWeb.Gettext) == "en"
  end

  # test "set accept language to ja", %{conn: conn} do
  # end

  test "set ja to default locale", %{conn: conn} do
    Locale.call(conn, "ja")
    assert Gettext.get_locale(EmbedChatWeb.Gettext) == "ja"
  end
end
