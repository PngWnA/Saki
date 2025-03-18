defmodule Saki.Core.Dispatcher do
  use GenServer
  require Logger
  alias Saki.Tasks.TaskContext
  alias Saki.Tasks.Util, as: TaskUtil

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    tasks = TaskUtil.valid_tasks

    Logger.info("Following tasks will be registered in Dispatcher: #{inspect(tasks)}")

    {:ok, %{tasks: tasks}}
  end

  # HTTP 서버에서 호출하는 비동기 메시지 전송 함수
  def dispatch(context) do
    GenServer.cast(__MODULE__, {:process_task, context})
  end

  ## 메시지를 받아서 적절한 Task 실행
  def handle_cast({:process_task, %TaskContext{} = context}, %{tasks: tasks} = state) do
      tasks
      |> Enum.filter(&(&1.should_handle?(context)))
      |> Enum.each(&(&1.execute(context)))
    {:noreply, state}
  end
end
