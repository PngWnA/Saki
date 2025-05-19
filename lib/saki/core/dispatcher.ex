defmodule Saki.Core.Dispatcher do
  use GenServer
  require Logger
  alias Saki.Tasks.TaskContext
  alias Saki.Tasks.Util, as: TaskUtil

  @type task_result :: {:ok, TaskContext.t()} | {:error, TaskContext.t(), term()}

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc "Dispatch a context to pre-filtered tasks"
  @spec dispatch(TaskContext.t(), [module()]) :: :ok
  def dispatch(%TaskContext{} = context, tasks) when is_list(tasks) do
    GenServer.cast(__MODULE__, {:dispatch, context, tasks})
  end

  # Server Callbacks

  @impl GenServer
  def init(_) do
    tasks = TaskUtil.valid_tasks()
    Logger.info("Loaded #{length(tasks)} tasks: #{inspect(tasks)}")
    {:ok, %{tasks: tasks}}
  end

  @impl GenServer
  def handle_cast({:dispatch, context, tasks}, state) do
    tasks
    |> Task.async_stream(&execute_task(&1, context), ordered: false)
    |> Stream.run()

    {:noreply, state}
  end

  # Private Functions

  @spec execute_task(module(), TaskContext.t()) :: task_result()
  defp execute_task(task_module, context) do
    task_name = task_module |> module_name()
    Logger.debug("Running #{task_name} with context #{inspect(context)}")

    try do
      case task_module.execute(context) do
        {:ok, _} = result ->
          Logger.debug("Task #{task_name} completed successfully")
          result

        {:error, _, reason} = error ->
          Logger.warning("Task #{task_name} failed: #{inspect(reason)}")
          error
      end
    rescue
      e ->
        Logger.error("Exception in #{task_name}: #{Exception.message(e)}")
        {:error, context, "Exception: #{Exception.message(e)}"}
    end
  end

  defp module_name(module) when is_atom(module) do
    module
    |> to_string()
    |> String.split(".")
    |> List.last()
  end
end
