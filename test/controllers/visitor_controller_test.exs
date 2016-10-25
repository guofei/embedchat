defmodule EmbedChat.VisitorControllerTest do
  use EmbedChat.ConnCase

  alias EmbedChat.Visitor
  @valid_attrs %{email: "some@content", name: "some content", note: "some content"}
  @invalid_attrs %{email: "nonmail"}

  setup %{conn: conn} do
    user = insert_user(username: "test")
    room = insert_room(user, %{})
    address = insert_address(user, room)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, address: address, room: room}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, visitor_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    visitor = Repo.insert! %Visitor{}
    conn = get conn, visitor_path(conn, :show, visitor)
    assert json_response(conn, 200)["data"] == %{"id" => visitor.id,
      "name" => visitor.name,
      "email" => visitor.email,
      "note" => visitor.note}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, visitor_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn, address: address, room: room} do
    conn = post conn, visitor_path(conn, :create), visitor: @valid_attrs, uuid: address.uuid, room_uuid: room.uuid
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Visitor, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, address: address, room: room} do
    conn = post conn, visitor_path(conn, :create), visitor: @invalid_attrs, uuid: address.uuid, room_uuid: room.uuid
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    visitor = Repo.insert! %Visitor{}
    conn = put conn, visitor_path(conn, :update, visitor), visitor: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Visitor, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    visitor = Repo.insert! %Visitor{}
    conn = put conn, visitor_path(conn, :update, visitor), visitor: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    visitor = Repo.insert! %Visitor{}
    conn = delete conn, visitor_path(conn, :delete, visitor)
    assert response(conn, 204)
    refute Repo.get(Visitor, visitor.id)
  end
end
