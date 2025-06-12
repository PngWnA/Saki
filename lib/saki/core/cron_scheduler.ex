defmodule Saki.Core.CronScheduler do
  @moduledoc """
  Schedules and executes tasks using cron expressions.
  """

  use GenServer
  require Logger

  alias Saki.Core.{Dispatcher, Concept.TaskContext}
  alias Crontab.CronExpression

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, __MODULE__))
  end

  @impl true
  def init(_opts) do
    schedule_tick()
    {:ok, %{tasks: %{}}}
  end

  @impl true
  def handle_info(:tick, state) do
    now = DateTime.utc_now()
    new_state = execute_due_tasks(state, now)
    schedule_tick()
    {:noreply, new_state}
  end

  @impl true
  def handle_call({:register_task, task}, _from, state) do
    if task.cron_schedule() do
      new_state = put_in(state.tasks[task], %{
        schedule: task.cron_schedule(),
        last_run: nil
      })
      {:reply, :ok, new_state}
    else
      {:reply, {:error, :no_schedule}, state}
    end
  end

  @impl true
  def handle_call({:unregister_task, task}, _from, state) do
    new_state = update_in(state.tasks, &Map.delete(&1, task))
    {:reply, :ok, new_state}
  end

  # Public API

  def register_task(task) do
    GenServer.call(__MODULE__, {:register_task, task})
  end

  def unregister_task(task) do
    GenServer.call(__MODULE__, {:unregister_task, task})
  end

  # Private functions

  defp schedule_tick do
    Process.send_after(self(), :tick, 1000)  # Check every second
  end

  defp execute_due_tasks(state, now) do
    Enum.reduce(state.tasks, state, fn {task, task_state}, acc_state ->
      if should_run?(task_state, now) do
        context = TaskContext.new(:cron, %{})
        Dispatcher.execute_task(task, context)

        # Update last run time
        put_in(acc_state.tasks[task].last_run, now)
      else
        acc_state
      end
    end)
  end

  defp should_run?(%{schedule: schedule, last_run: last_run}, now) do
    case last_run do
      nil -> true
      last_run ->
        # Convert DateTime to NaiveDateTime for Crontab
        now_naive = DateTime.to_naive(now)
        last_run_naive = DateTime.to_naive(last_run)

        # Check if the current time matches the cron schedule
        # and if it's a new minute since the last run
        CronExpression.match?(schedule, now_naive) and
          NaiveDateTime.diff(now_naive, last_run_naive, :second) >= 60
    end
  end
end
