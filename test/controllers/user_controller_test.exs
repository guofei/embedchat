defmodule EmbedChat.UserControllerTest do
  use EmbedChat.ConnCase
  alias EmbedChat.User

  @valid_attrs %{password: "some content", email: "some@content.com", name: "name"}
  @invalid_attrs %{}

  defp room_count(query), do: Repo.one(from v in query, select: count(v.id))

  test "creates user and user's room when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert redirected_to(conn) == page_path(conn, :index)
    user = Repo.get_by(User, %{email: @valid_attrs[:email]})
    assert room_count(assoc(user, :rooms)) == 1
  end
end
