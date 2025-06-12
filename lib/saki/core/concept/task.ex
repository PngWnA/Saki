defmodule Saki.Core.Concept.Task do
  @moduledoc """
  Defines the behaviour for tasks in Saki.
  Tasks must implement the following callbacks:
  - execute/1: Executes the task with the given context
  - cron_schedule/0: Returns the cron schedule for this task, if any
  """

  alias Saki.Core.Concept.TaskContext

  @callback name() :: String.t()
  @callback description() :: String.t()
  @callback cron_schedule() :: String.t() | nil
  @callback execute(context :: TaskContext.t()) :: {:ok, any()} | {:error, any()}

  defmacro __using__(opts) do
    quote do
      @behaviour Saki.Core.Concept.Task

      @name unquote(opts[:name])
      @description unquote(opts[:description] || "")
      @cron_schedule unquote(opts[:cron_schedule] || nil)

      @impl true
      def name, do: @name
      @impl true
      def description, do: @description
      @impl true
      def cron_schedule, do: @cron_schedule

      @impl true
      def execute(context) do
        # 기본 구현은 에러를 반환합니다.
        # 각 Task 모듈에서 이 함수를 구현해야 합니다.
        {:error, :not_implemented}
      end

      defoverridable [execute: 1]
    end
  end
end
