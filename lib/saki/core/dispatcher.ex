defmodule Saki.Core.Dispatcher do
  @moduledoc """
  Dispatches and executes tasks.
  """

  require Logger

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
end
