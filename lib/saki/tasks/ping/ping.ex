defmodule Saki.Tasks.Ping do
  @behaviour Saki.Tasks.TaskSpecification

  alias Saki.Tasks.TaskContext

  def should_process?(%TaskContext{} = context) do
    context.request.url === "/ping"
  end

  def process(%TaskContext{} = context) do
    # @Note: Implement this
    {:ok, context}
  end
end
