defmodule Saki.Tasks.TaskSpecification do

  alias Saki.Tasks.TaskContext

  @callback should_process?(context :: %TaskContext{}) :: boolean()
  @callback process(context :: %TaskContext{}) ::
    {:ok, context :: %TaskContext{}}
    | {:error, context :: %TaskContext{}, reason :: term()}
end
