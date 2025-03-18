defmodule Saki.Core.CronScheduler do
  use Quantum, otp_app: :saki

  alias Saki.Core.Dispatcher
  alias Saki.Tasks.TaskContext
  alias Saki.Tasks.Util, as: TaskUtil

  require Logger

  def init(opt) do
    scheduled_tasks = TaskUtil.valid_tasks
    |> Enum.filter(&(&1.cron_schedule() !== nil))

    Logger.info("Following tasks will be handled in Cron Executor: #{inspect(scheduled_tasks)}")

    scheduled_tasks
    |> Enum.each(
      &(
        with {:ok, schedule} <- Crontab.CronExpression.Parser.parse(&1.cron_schedule()) do
          new_job()
          |> Quantum.Job.set_name(&1)
          |> Quantum.Job.set_schedule(schedule)
          |> Quantum.Job.set_task(fn -> run(&1) end)
          |> Quantum.Job.set_state(:active)
          |> add_job()
        end
      )
    )
    opt
  end

  defp run(task) do
    IO.puts "gogo"
    context = %TaskContext{
      request: %{"source" => "cron", "task" => task},
      context: %{},
      log: %{}
    }

    context |> Dispatcher.dispatch
  end

end
