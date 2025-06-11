defmodule Saki.Core.TaskRegistry do
  @moduledoc """
  Registry for managing tasks.
  """

  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, __MODULE__))
  end

  def init(_opts) do
    tasks = discover_saki_tasks()
    Logger.info("TaskRegistry discovered following tasks: #{inspect(tasks)}")
    {:ok, tasks}
  end

  def handle_call(:tasks, _from, state) do
    {:reply, state}
  end

  defp discover_saki_tasks do
    # 모든 모듈이 로드되어 있어야 함
    with modules <- Application.spec(:saki, :modules) do
      modules
      |> Code.ensure_all_loaded

      modules
      |> Enum.filter(&is_saki_task?/1)
    end
  end

  defp is_saki_task?(module) do
    module.module_info(:attributes)
    |> Keyword.get(:behaviour, [])
    |> Enum.any?(&(&1 == Saki.Core.Concept.Task))
  end

  def tasks do
    GenServer.call(__MODULE__, :tasks)
  end

  def find_task(%{task: task_name}) do
    tasks()
    |> Enum.find(fn task -> task.task_name == task_name end)
  end
end
