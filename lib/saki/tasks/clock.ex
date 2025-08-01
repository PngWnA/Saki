defmodule Saki.Tasks.Clock do
  @moduledoc """
  Test task for Saki.
  """

  use Saki.Core.Concept.Task,
    name: "Clock",
    description: "Test task for Saki"

  require Logger

  @impl true
  def execute(_context) do
    {:ok, "Hello world!"}
  end
end
