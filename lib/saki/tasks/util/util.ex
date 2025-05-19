defmodule Saki.Tasks.Util do
  @doc """
  등록 가능한 Task 반환
  """
  def valid_tasks do
    with modules <- Application.spec(:saki, :modules) do
      modules
      |> Code.ensure_all_loaded()

      modules
      |> Enum.filter(&implements_task_specification?/1)
    end
  end

  @doc """
  Saki.Tasks.TaskSpecification을 구현하였는지 확인
  """
  def implements_task_specification?(module) do
    behaviours = module.module_info(:attributes)
    |> Keyword.get(:behaviour, [])

    Saki.Tasks.TaskSpecification in behaviours
  end
end
