defmodule Saki.Core.Concept.TaskContext do
  @moduledoc """
  Defines the context structure for task execution.
  """

  @type by :: :cron | :http | :manual

  @type t :: %__MODULE__{
    id: String.t(),
    by: by(),
    timestamp: DateTime.t(),
    request: map()
  }

  defstruct [:id, :by, :timestamp, :request]

  @doc """
  Creates a new task context with the given parameters.
  """
  def new(by, request \\ %{}) do
    %__MODULE__{
      id: UUID.uuid4(),
      by: by,
      timestamp: DateTime.utc_now(),
      request: request
    }
  end
end
