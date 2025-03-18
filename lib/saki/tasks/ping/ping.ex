defmodule Saki.Tasks.Ping do
  @behaviour Saki.Tasks.TaskSpecification

  alias Saki.Tasks.TaskContext

  def cron_schedule do
    nil
  end

  def should_handle?(%TaskContext{} = context) do
    context.request.url === "/ping"
  end

  def execute(%TaskContext{} = context) do
    # @Note: Implement this if needed
    {:ok, context}
  end
end
