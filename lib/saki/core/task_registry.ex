defmodule Saki.Core.TaskRegistry do
  @moduledoc """
  Registry for managing tasks.
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, __MODULE__))
  end

  def init(opts) do
    {:ok, %{}}
  end

  def register_task(name, task) do
    GenServer.call(__MODULE__, {:register_task, name, task})
  end

  def get_task(name) do
    GenServer.call(__MODULE__, {:get_task, name})
  end

  def handle_call({:register_task, name, task}, _from, state) do
    {:reply, :ok, Map.put(state, name, task)}
  end

  def handle_call({:get_task, name}, _from, state) do
    {:reply, Map.get(state, name), state}
  end

  def handle_call(:get_tasks, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_task_names, _from, state) do
    {:reply, Map.keys(state), state}
  end

  def handle_call(:get_task_modules, _from, state) do
    {:reply, Enum.map(state, fn {_, task} -> task end), state}
  end

  def handle_call(:get_task_modules, _from, state) do
    {:reply, Enum.map(state, fn {_, task} -> task end), state}
  end

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
