defmodule Saki.Tasks.TaskContext do

  @derive Jason.Encoder
  defstruct [
    # Task ID
    id: :crypto.strong_rand_bytes(16) |> Base.encode16,
    # For handling or dispatching request
    request: %{},
    # For managing context while processing request
    context: %{},
    # For leaving log for finished job
    log: %{},
  ]

end
