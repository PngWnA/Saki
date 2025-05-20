defmodule Saki.Core.HttpServer do
  @moduledoc """
  Handles HTTP endpoints and executes tasks through web requests.
  Automatically registers endpoints from task modules and handles both sync and async execution.
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

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(opts) do
    port = Keyword.get(opts, :port, 31413)
    Logger.info("Starting HTTP server on port #{port}")

    tasks = register_tasks()
    Logger.info("Following tasks are registered: #{inspect(tasks)}")

    # Start the HTTP server
    Plug.Cowboy.http(__MODULE__, [], port: port)
  end

  # 통합된 엔드포인트
  post "/" do
    with {:ok, task_name} <- Map.fetch(conn.body_params, "task"),
         {:ok, task_module} <- get_task_module(task_name),
         context = TaskContext.new(:http, conn.body_params),
         {:ok, result} <- execute_task(task_module, context) do
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

  # Health check endpoint
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

  defp register_tasks do
    :code.all_loaded()
    |> Enum.filter(fn {module, _} ->
      module
      |> Atom.to_string()
      |> String.starts_with?("Elixir.Saki.Tasks.")
    end)
    |> Enum.map(fn {module, _} -> module end)
    |> Enum.filter(&implements_task_behaviour?/1)
    |> Enum.map(fn module ->
      {module.task_name(), %{
        module: module,
        description: module.description(),
        endpoint: module.http_endpoint()
      }}
    end)
    |> Map.new()
  end

  defp implements_task_behaviour?(module) do
    module.module_info(:attributes)
    |> Keyword.get(:behaviour, [])
    |> Enum.any?(&(&1 == Saki.Core.Concept.Task))
  end

  defp get_task_module(task_name) do
    module_name = "Elixir.Saki.Tasks.#{Macro.camelize(task_name)}"

    case Code.ensure_loaded(String.to_existing_atom(module_name)) do
      {:module, module} -> {:ok, module}
      _ -> {:error, :not_found}
    end
  end

  defp execute_task(task_module, context) do
    Dispatcher.execute_task(task_module, context)
  end
end
