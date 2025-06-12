defmodule Saki.Core.HttpServer do
  @moduledoc """
  Handles HTTP endpoints and executes tasks through web requests.
  """

  use Plug.Router
  require Logger

  alias Saki.Core.{Dispatcher, Concept.TaskContext, Concept.Self, TaskRegistry}

  plug :match

  plug Plug.Logger
  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason

  plug :dispatch

  get "saki" do
    send_json_response(conn, 200, Self.meta())
  end

  get "saki/tasks" do
    send_json_response(conn, 200, TaskRegistry.get_tasks())
  end

  post "task" do
    Logger.info("Received request: #{inspect(conn.body_params)}")
    with {:ok, task_name} <- Map.fetch(conn.body_params, "task"),
      {:ok, module} <- TaskRegistry.get_task(task_name),
      task_context <- TaskContext.new(:http, conn.body_params),
      {:ok, status} <- Dispatcher.execute_task(module, task_context)
    do
      send_json_response(conn, 200, %{
        task_id: task_context.id,
        status: status
      })
    else
      :error ->
        send_json_response(conn, 400, %{
          reason: "Cannot process request."
        })
      {:error, :not_found} ->
        send_json_response(conn, 404, %{
          reason: "No task found to handle this request."
        })
      {:error, reason} ->
        send_json_response(conn, 500, %{
          reason: inspect(reason)
        })
    end
  end

  # Fallback route
  match _ do
    # do nothing
    send_resp(conn, 418, "I'm Saki")
  end

  defp send_json_response(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end

end
