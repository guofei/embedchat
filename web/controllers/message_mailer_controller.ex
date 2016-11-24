defmodule EmbedChat.MessageMailerController do
  use EmbedChat.Web, :controller

  alias EmbedChat.Address
  alias EmbedChat.Message
  alias EmbedChat.MessageMailer
  alias EmbedChat.Room

  plug Guardian.Plug.EnsureAuthenticated

  def create(conn, %{"message_mailer" => params}) do
    changeset = MessageMailer.changeset(%MessageMailer{}, params)
    user = Guardian.Plug.current_resource(conn)

    address =
      Address
      |> Repo.get_by(uuid: params["address_uuid"])
    address =
      Address
      |> Address.get_by_master(user.id, address.id)
      |> Ecto.Query.preload([:visitor])
      |> Repo.one()

    room =
      Room
      |> Ecto.Query.preload([:project])
      |> Repo.get_by(uuid: params["room_uuid"])

    messages =
      Message
      |> Message.preload_for_room_and_address_except_email_request(room.id, address.id, 10)
      |> Repo.all

    address.visitor
    |> EmbedChat.VisitorEmail.send_msgs(room.project, messages)
    |> EmbedChat.Mailer.deliver_later
    conn
    |> render("show.json", message_mailer: Ecto.Changeset.apply_changes(changeset))
  end
end
