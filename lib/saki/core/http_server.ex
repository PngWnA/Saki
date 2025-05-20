defmodule Saki.Core.HttpServer do
  @moduledoc """
  Handles HTTP endpoints and executes tasks through web requests.
  """

  use Plug.Router
  require Logger

  alias Saki.Core.{Dispatcher, Concept.TaskContext}

  plug Plug.Logger
  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  plug :dispatch

  post _ do
    Logger.info("Received request: #{inspect(conn)}")
    with {:ok, task_name} <- Map.fetch(conn.body_params, "task"),
         {:ok, task_module} <- Dispatcher.get_task(task_name),
         context = TaskContext.new(:http, conn.body_params),
         {:ok, result} <- Dispatcher.execute_task(task_module, context) do
      send_json_response(conn, 200, %{
        status: "success",
        task_id: context.id,
        result: result
      })
    else
      {:error, :not_found} ->
        send_json_response(conn, 404, %{
          status: "error",
          reason: "Task not found"
        })
      {:error, reason} ->
        send_json_response(conn, 500, %{
          status: "error",
          reason: inspect(reason)
        })
    end
  end

  get "/health" do
    send_json_response(conn, 200, %{status: "ok"})
  end

  # Fallback route
  match _ do
    send_json_response(conn, 404, %{
      status: "error",
      reason: "Not found"
    })
  end

  # Private functions

  defp send_json_response(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end
end
