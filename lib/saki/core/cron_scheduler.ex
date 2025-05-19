defmodule Saki.Core.CronScheduler do
  alias Saki.Tasks.TaskContext
  alias Saki.Tasks.Util, as: TaskUtil
  alias Saki.Core.Dispatcher
  alias Saki.Tasks.Clock

  require Logger

  @doc """
  Initialize the CronScheduler during application startup.
  This only logs available tasks; actual scheduling is done by Oban.Plugins.Cron.
  """
  def init do
    scheduled_tasks = TaskUtil.valid_tasks()
    |> Enum.filter(&(&1.cron_schedule() !== nil))

    Logger.info("Following tasks will be handled in Cron Executor: #{inspect(scheduled_tasks)}")
    :ok
  end

  @doc """
  Called by Oban.Plugins.Cron based on the crontab configuration.
  """
  def run_clock_task(_) do
    Logger.debug("Running clock task via Oban")
    context = %TaskContext{
      id: :crypto.strong_rand_bytes(16) |> Base.encode16(),
      request: %{:from => :cron, :task => Clock},
      context: %{},
      log: %{}
    }

    Dispatcher.dispatch(context, [Clock])
    :ok
  end
end
