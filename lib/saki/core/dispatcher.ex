defmodule Saki.Core.Dispatcher do
  use GenServer
  require Logger
  alias Saki.Core.CronScheduler
  alias Saki.Tasks.TaskContext
  alias Saki.Tasks.Util, as: TaskUtil

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    tasks = TaskUtil.valid_tasks
    Logger.info("Following tasks will be registered in Dispatcher: #{inspect(tasks)}")

    CronScheduler.start()

    {:ok, %{tasks: tasks}}
  end

  # HTTP 서버에서 호출하는 비동기 메시지 전송 함수
  def dispatch(context) do
    GenServer.cast(__MODULE__, {:dispatch, context})
  end

  ## 메시지를 받아서 적절한 Task 실행
  def handle_cast({:dispatch, %TaskContext{} = context}, %{tasks: tasks} = state) do
      Logger.debug("Dispatcher will process request with context #{inspect(context)}")
      elligible_tasks = tasks
      |> Enum.filter(&(&1.should_handle?(context)))

      case elligible_tasks do
        []
          -> Logger.info("No tasks are found elligible for context #{inspect(context)}")
        _ ->
          Logger.info("Tasks #{inspect(elligible_tasks)} will process the context #{inspect(context)}")
          elligible_tasks
          |> Enum.each(&(&1.execute(context)))
      end
    {:noreply, state}
  end
end
