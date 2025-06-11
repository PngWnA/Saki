defmodule Saki.Core.Dispatcher do
  @moduledoc """
  Dispatches and executes tasks.
  Manages the registry of available tasks.
  """

  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, __MODULE__))
  end

  @impl true
  @spec init(any()) :: {:ok, any()}
  def init(_opts) do
    tasks = discover_tasks()
    |> Enum.map(fn module -> {module.name(), module} end)
    |> Enum.into(%{})
    Logger.info("Following tasks are registered: #{inspect(tasks |> Map.values)}")
    {:ok, tasks}
  end

  @impl true
  def handle_call(:get_tasks, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:get_task, task_name}, _from, state) do
    case Map.fetch(state, task_name) do
      {:ok, module} -> {:reply, module, state}
      :error -> {:reply, :not_found, state}
    end
  end

  # Public API

  @doc """
  Returns all registered tasks.
  """
  def get_tasks do
    GenServer.call(__MODULE__, :get_tasks)
  end

  @doc """
  Returns a specific task by name.
  """
  def get_task(task_name) do
    GenServer.call(__MODULE__, {:get_task, task_name})
  end

  @doc """
  Executes a task with the given context.
  """
  def execute_task(task, context) do
    Logger.info("Executing task #{task} with context: #{inspect(context)}")

    try do
      result = task.execute(context)
      Logger.info("Task #{task} executed successfully: #{inspect(result)}")
      result
    rescue
      e ->
        Logger.error("Task #{task} execution failed: #{inspect(e)}")
        {:error, e}
    end
  end

  defp discover_tasks do
    # 모든 모듈이 로드되어 있어야 함
    with modules <- Application.spec(:saki, :modules) do
      modules
      |> Code.ensure_all_loaded

      modules
      |> Enum.filter(&isTask?/1)
    end
  end

  defp isTask?(module) do
    module.module_info(:attributes)
    |> Keyword.get(:behaviour, [])
    |> Enum.any?(&(&1 == Saki.Core.Concept.Task))
  end

end
