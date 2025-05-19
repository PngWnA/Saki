defmodule Saki.Core.HTTPServer do
  use Plug.Router

  require Logger
  alias Saki.Core.{Self, Dispatcher}
  alias Saki.Tasks.{TaskContext, Util}

  plug :match
  plug :dispatch

  # For retrieving metadata
  get "/saki" do
    try do
      json = Jason.encode!(Self.info())
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, json)
    rescue
      e ->
        Logger.error("Failed to encode JSON: #{inspect(e)}")
        send_resp(conn, 500, "Internal Server Error")
    end
  end

  # Catch all route
  match _ do
    with {:ok, body, _} <- Plug.Conn.read_body(conn),
         context <- build_context(conn, body),
         {:ok, handlers} <- find_handlers(context) do

      dispatch(conn, context, handlers)
    else
      {:error, :no_handlers, context} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(404, Jason.encode!(%{id: context.id, error: "No handler found"}))

      {:error, reason} ->
        Logger.error("Request error: #{inspect(reason)}")
        send_resp(conn, 500, "Internal Server Error")
    end
  end

  defp build_context(conn, body) do
    %TaskContext{request: %{
      from: :http,
      method: conn.method,
      url: conn.request_path,
      params: conn.params,
      body: body
    }}
  end

  defp find_handlers(context) do
    case Util.valid_tasks() |> Enum.filter(&(&1.should_handle?(context))) do
      [] -> {:error, :no_handlers, context}
      handlers -> {:ok, handlers}
    end
  end

  defp dispatch(conn, context, handlers) do

    Dispatcher.dispatch(context, handlers)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(202, Jason.encode!(%{
      id: context.id,
      status: "Dispatched"
    }))
  end
end
