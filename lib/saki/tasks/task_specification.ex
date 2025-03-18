defmodule Saki.Tasks.TaskSpecification do
  @moduledoc """
  해당 TaskSpecification 내 함수를 구현해야 Dispatcher에 등록될 수 있습니다.
  """

  alias Saki.Tasks.TaskContext

  @doc """
  Cron 형식으로 Task가 수행될 경우 cron expression을 반환
  """
  @callback cron_schedule() :: String.t() | nil

  @doc """
  Context를 확인하여 해당 task가 실행되어야하는지 판단
  """
  @callback should_handle?(context :: %TaskContext{}) :: boolean()

  @doc """
  실제 Task 실행 로직을 구현
  """
  @callback execute(context :: %TaskContext{} | nil) ::
    {:ok, context :: %TaskContext{}}
    | {:error, context :: %TaskContext{}, reason :: term()}
end
