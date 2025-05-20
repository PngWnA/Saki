defmodule Saki.Core.CronScheduler do
  @moduledoc """
  Schedules and executes tasks using cron expressions.
  """

  alias Saki.Core.Dispatcher

  @doc """
  Executes a task immediately.
  """
  def execute_task(task) do
    Dispatcher.execute_task(task)
  end

  @doc """
  Registers a task for cron scheduling.
  """
  def register_task(task) do
    if task.schedule do
      # TODO: Implement cron scheduling using Crontab
      :ok
    else
      {:error, :no_schedule}
    end
  end

  @doc """
  Unregisters a task from cron scheduling.
  """
  def unregister_task(task_id) do
    # TODO: Implement cron scheduling using Crontab
    :ok
  end
end
