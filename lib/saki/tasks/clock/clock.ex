defmodule Saki.Tasks.Clock do
  @behaviour Saki.Tasks.TaskSpecification

  alias Saki.Tasks.TaskContext

  def cron_schedule do
    "* * * * *"
  end

  def should_handle?(context) do
    IO.puts(context)
    true
  end

  def execute(%TaskContext{} = context) do
    # @Note: Implement this if needed
    IO.puts "clock"
    {:ok, context}
  end
end
