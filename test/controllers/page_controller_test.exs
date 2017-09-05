defmodule EmbedChatWeb.PageControllerTest do
  use EmbedChatWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Lewini"
  end
end
