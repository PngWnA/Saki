defmodule Saki.Tasks.Util do

  @doc """
  등록 가능한 Task 반환
  """
  def valid_tasks do
    with modules <- Application.spec(:saki, :modules) do
      modules
      |> Code.ensure_all_loaded

      modules
      |> Enum.filter(&implements_task_specification?/1)
    end
  end

  @doc """
  Saki.Tasks.TaskSepcification를 구현하였는지 확인
  """
  def implements_task_specification?(module) do
    # 더 우아한 방법이 있을까? 언어 명세에는 없는 것으로 보임
    function_exported?(module, :cron_schedule, 0)
    && function_exported?(module, :should_handle?, 1)
    && function_exported?(module, :execute, 1)
  end

end
