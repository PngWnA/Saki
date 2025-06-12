defmodule Saki.Core.Dispatcher do
  @moduledoc """
  Dispatches and executes tasks.
  Manages the registry of available tasks.
  """

  use GenServer
  require Logger

  @spec start_link(keyword()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, __MODULE__))
  end

  def init(_opts) do
    {:ok, %{}}
  end


  @doc """
  Executes a task with the given context.
  """
  def execute_task(task, context) do
    Logger.info("Executing task #{task} with context: #{inspect(context)}")

    try do
      with {:ok, result} <- task.execute(context) do
        Logger.info("Task #{task} executed successfully: #{inspect(result)}")
        {:ok, result}
      else
        {:error, reason} ->
          Logger.error("Task #{task} failed: #{inspect(reason)}")
          {:error, reason}
      end
    rescue
      e ->
        Logger.error("Dispatcher failed: #{inspect(e)}")
        {:error, e}
    end
  end

end
