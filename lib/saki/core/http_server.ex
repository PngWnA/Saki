defmodule Saki.Core.HTTPServer do
  use Plug.Router

  require Logger
  alias Saki.Core.{Self, Dispatcher}
  alias Saki.Tasks.TaskContext

  plug :match
  plug :dispatch

  # For retrieving metadata
  get "/saki" do
    with {:ok, json} <- Jason.encode(%Self{}) do
      send_resp(conn, 200, json)
    else
      {:error, reason} ->
        Logger.error("Failed to encode JSON: #{inspect(reason)}")
        send_resp(conn, 500, inspect(reason))
    end
  end

  # Construct task context and let dispatcher do the job
  match _ do
    with {:ok, body, _} <- Plug.Conn.read_body(conn) do

      context = %TaskContext{
        request: %{
          method: conn.method,
          url: conn.request_path,
          params: conn.params,
          body: body
        },
      }
      context |> Dispatcher.dispatch

      send_resp(conn, 202, Jason.encode!(context))
    else
      {:error, reason} ->
        Logger.error("Failed to process HTTP request: #{inspect(reason)}")
        send_resp(conn, 500, inspect(reason))
    end
  end

end
