defmodule Saki.Core.Dispatcher do
  @moduledoc """
  Dispatches and executes tasks.
  """

  @doc """
  Executes a task by applying the module function with the given arguments.
  """
  def execute_task(task) do
    apply(task.module, task.function, task.args)
  end
end
