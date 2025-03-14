defmodule Saki.Core.Dispatcher do
  use GenServer
  require Logger
  alias Saki.Tasks.TaskContext

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do

    # 명시적으로 Tasks를 포함한 모든 모듈을 로드하고 시작
    with modules <- Application.spec(:saki, :modules) do
      modules
      |> Code.ensure_all_loaded

      tasks = modules
      |> Enum.filter(&implements_task_specification?/1)

      Logger.info("Following tasks are registered: #{inspect(tasks)}")

      {:ok, %{tasks: tasks}}
    end
  end

  #Saki.Tasks.TaskSepcification를 구현하였는지 확인
  defp implements_task_specification?(module) do
    # 더 우아한 방법이 있을까? 언어 명세에는 없는 것으로 보임
    function_exported?(module, :should_process?, 1)
    && function_exported?(module, :process, 1)
  end

  # HTTP 서버에서 호출하는 비동기 메시지 전송 함수
  def dispatch(context) do
    GenServer.cast(__MODULE__, {:process_task, context})
  end

  ## 메시지를 받아서 적절한 Task 실행
  def handle_cast({:process_task, %TaskContext{} = context}, %{tasks: tasks} = state) do
      tasks
      |> Enum.filter(&(&1.should_process?(context)))
      |> Enum.each(&(&1.process(context)))
    {:noreply, state}
  end
end
