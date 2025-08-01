defmodule Saki.Core.TaskRegistry do
  @moduledoc """
  Registry for managing tasks.
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
    case GenServer.call(__MODULE__, {:get_task, task_name}) do
      :not_found -> {:error, :not_found}
      module -> {:ok, module}
    end
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
