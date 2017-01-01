defmodule EmbedChat.NewsControllerTest do
  use EmbedChat.ConnCase

  alias EmbedChat.News
  @valid_attrs %{content_en: "some content", content_ja: "some content", content_zh: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, news_path(conn, :index)
    assert html_response(conn, 200) =~ "Release Notes"
  end

  test "shows chosen resource", %{conn: conn} do
    news = Repo.insert! %News{}
    conn = get conn, news_path(conn, :show, news)
    assert html_response(conn, 200) =~ "Show news"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, news_path(conn, :show, -1)
    end
  end
end
