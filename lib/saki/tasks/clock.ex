defmodule Saki.Tasks.Clock do
  @moduledoc """
  A simple clock task that can be triggered via HTTP or cron.
  """

  use Saki.Core.Concept.Task,
    name: "Clock",
    description: "A simple clock task that can be triggered via HTTP or cron",
    http_endpoint: "/clock",
    cron_schedule: "*/1 * * * *"

  require Logger

  @impl true
  def execute(context) do
    case context.by do
      :cron ->
        Logger.info("Clock task executed with context: #{inspect(context)}")

      :http ->
        Logger.info("Clock task executed with context: #{inspect(context)}")

      :manual ->
        Logger.info("Clock task executed with context: #{inspect(context)}")
    end
    {:ok, context}
  end
end
