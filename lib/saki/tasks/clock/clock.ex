defmodule Saki.Tasks.Clock do
  @behaviour Saki.Tasks.TaskSpecification

  alias Saki.Tasks.TaskContext

  def cron_schedule do
    "* * * * *"
  end

  def should_handle?(%TaskContext{} = context) do
    case context.request.from do
      :cron -> true
      :http -> false
    end
  end

  def execute(%TaskContext{} = context) do
    IO.puts "clock"
    {:ok, context}
  end
end
