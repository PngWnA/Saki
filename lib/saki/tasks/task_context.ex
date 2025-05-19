defmodule Saki.Tasks.TaskContext do

  @derive Jason.Encoder
  defstruct [
    id: :crypto.strong_rand_bytes(16) |> Base.encode16(),
    request: %{},
    context: %{},
    log: %{},
  ]

  @type t :: %__MODULE__{
    id: String.t(),
    request: map(),
    context: map(),
    log: map()
  }
end
