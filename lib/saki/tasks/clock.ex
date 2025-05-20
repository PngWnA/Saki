defmodule Saki.Tasks.Clock do
  @moduledoc """
  A simple clock task that can be triggered via HTTP or cron.
  """

  @behaviour Saki.Core.Concept.Task
  require Logger

  @impl true
  def http_endpoint, do: "/clock"

  @impl true
  def cron_schedule, do: "*/1 * * * *"

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
