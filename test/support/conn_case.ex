defmodule EmbedChatWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias EmbedChat.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import EmbedChatWeb.Router.Helpers

      import EmbedChatWeb.TestHelpers

      # The default endpoint for testing
      @endpoint EmbedChatWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EmbedChat.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(EmbedChat.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
