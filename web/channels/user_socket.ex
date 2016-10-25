defmodule EmbedChat.UserSocket do
  use Phoenix.Socket
  import Guardian.Phoenix.Socket

  ## Channels
  channel "rooms:*", EmbedChat.RoomChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket, check_origin: false
  transport :longpoll, Phoenix.Transports.LongPoll, check_origin: false

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"token" => "", "distinct_id" => distinct_id}, socket) do
    connect(%{"distinct_id" => distinct_id}, socket)
  end

  @max_age 2 * 7 * 24 * 60 * 60

  def connect(%{"token" => token, "distinct_id" => distinct_id}, socket) do
    case Ecto.UUID.cast(distinct_id) do
      {:ok, distinct_id} ->
        case sign_in(socket, token) do
          {:ok, authed_socket, _guardian_params} ->
            user = Guardian.Phoenix.Socket.current_resource(authed_socket)
            {:ok,
             authed_socket
             |> assign(:current_user, user)
             |> assign(:distinct_id, distinct_id)}
          _ ->
            {:ok, assign(socket, :distinct_id, distinct_id)}
        end
      {:error, _reason} ->
        :error
    end
  end

  def connect(%{"distinct_id" => distinct_id}, socket) do
    case Ecto.UUID.cast(distinct_id) do
      {:ok, distinct_id} ->
        {:ok, assign(socket, :distinct_id, distinct_id)}
      {:error, _reason} ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     EmbedChat.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket), do: "users_socket:#{socket.assigns.distinct_id}"
end
