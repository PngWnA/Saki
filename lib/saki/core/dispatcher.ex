defmodule Saki.Core.Dispatcher do
  @moduledoc """
  Dispatches and executes tasks.
  Manages the registry of available tasks.
  """

  use GenServer
  require Logger

  alias Saki.Core.Concept.Task

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, __MODULE__))
  end

  @impl true
  def init(_opts) do
    tasks = discover_tasks()
    Logger.info("Following tasks are registered: #{inspect(tasks)}")
    {:ok, %{tasks: tasks}}
  end

  @impl true
  def handle_call(:get_tasks, _from, state) do
    {:reply, state.tasks, state}
  end

  @impl true
  def handle_call({:get_task, task_name}, _from, state) do
    result = case Map.get(state.tasks, task_name) do
      %{module: module} -> {:ok, module}
      nil -> {:error, :not_found}
    end
    {:reply, result, state}
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

  # Private functions

  defp discover_tasks do
    :code.all_loaded()
    |> Enum.map(fn {module, _} -> module end)
    |> Enum.filter(&(String.starts_with?("Saki.Tasks.", Atom.to_string(&1))))
    |> Enum.filter(&implements_task_behaviour?/1)
    |> Enum.filter(&(&1.http_endpoint() != nil))
    |> Enum.map(&(
      %{
        module: &1,
        endpoint: &1.http_endpoint()
      }
    ))
    |> Map.new()
  end

  defp implements_task_behaviour?(module) do
    module.module_info(:attributes)
    |> Keyword.get(:behaviour, [])
    |> Enum.any?(&(&1 == Task))
  end
end
