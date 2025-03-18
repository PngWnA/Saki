defmodule Saki.Tasks.Ping do
  @behaviour Saki.Tasks.TaskSpecification

  require Logger
  alias Saki.Tasks.TaskContext

  def cron_schedule do
    nil
  end

  def should_handle?(%TaskContext{} = context) do
    case context.request.from do
      :cron -> false
      :http -> context.request.url === "/ping"
    end
  end

  def execute(%TaskContext{} = context) do
    # Note: Implement this if needed
    Logger.info("pong!")
    {:ok, context}
  end
end
