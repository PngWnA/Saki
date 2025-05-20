defmodule Saki.Core.HttpServer do
  @moduledoc """
  Handles HTTP endpoints and executes tasks through web requests.
  """

  alias Saki.Core.Dispatcher

  @doc """
  Executes a task immediately.
  """
  def execute_task(task) do
    Dispatcher.execute_task(task)
  end

  @doc """
  Registers a task for HTTP endpoint.
  """
  def register_task(task) do
    if task.endpoint do
      # TODO: Implement HTTP endpoint registration
      :ok
    else
      {:error, :no_endpoint}
    end
  end

  @doc """
  Unregisters a task from HTTP endpoint.
  """
  def unregister_task(task_id) do
    # TODO: Implement HTTP endpoint unregistration
    :ok
  end
end
