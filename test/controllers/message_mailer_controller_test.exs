defmodule EmbedChat.MessageMailerControllerTest do
  use EmbedChat.ConnCase

  alias EmbedChat.MessageMailer
  @invalid_attrs %{}

  setup %{conn: conn} do
    user = insert_user(username: "test")
    room = insert_room(user, %{})
    visitor = insert_visitor
    address = insert_address(visitor, room)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, room: room, address: address}
  end

  test "creates and renders resource when data is valid", %{conn: conn, room: room, address: address} do
    insert_message address, room
    mailer = %{"address_uuid" => address.uuid, "room_uuid" => room.uuid}
    conn = post conn, message_mailer_path(conn, :create), message_mailer: mailer
    assert json_response(conn, 200)["data"]
  end

  # test "does not create resource and renders errors when data is invalid", %{conn: conn, room: room, address: address} do
  #   insert_message address, room
  #   conn = post conn, message_mailer_path(conn, :create), message_mailer: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  defp insert_message(address, room) do
    Repo.insert! %EmbedChat.Message{from_id: address.id, room_id: room.id}
  end
end
