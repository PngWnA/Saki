defmodule Saki.Tasks.TaskContext do

  @derive Jason.Encoder
  defstruct [
    id: nil,
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
