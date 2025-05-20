defmodule Saki.Core.Concept.Task do
  @moduledoc """
  Defines the behaviour for tasks in Saki.
  Tasks must implement the following callbacks:
  - execute/1: Executes the task with the given context
  - http_endpoint/0: Returns the HTTP endpoint for this task, if any
  - cron_schedule/0: Returns the cron schedule for this task, if any
  """

  alias Saki.Core.Concept.TaskContext

  @doc """
  Executes the task with the given context.
  Returns {:ok, result} on success or {:error, reason} on failure.
  """
  @callback execute(context :: TaskContext.t()) :: {:ok, any()} | {:error, any()}

  @doc """
  Returns the HTTP endpoint for this task, if any.
  Returns nil if this task is not available via HTTP.
  """
  @callback http_endpoint() :: String.t() | nil

  @doc """
  Returns the cron schedule for this task, if any.
  Returns nil if this task is not scheduled.
  """
  @callback cron_schedule() :: String.t() | nil
end
