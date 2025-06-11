defmodule Saki.Core.Concept.Self do
  @moduledoc """
  Represents the application's self-description containing metadata from mix.exs
  """

  defstruct [:name, :version, :description]

  def meta do
    %__MODULE__{
      name: Application.get_application(__MODULE__),
      version: Application.spec(Application.get_application(__MODULE__), :vsn),
      description: Application.spec(Application.get_application(__MODULE__), :description)
    }
  end
end

defimpl Jason.Encoder, for: Saki.Core.Concept.Self do
  def encode(self, opts) do
    Jason.Encode.map(%{
      name: self.name |> to_string(),
      version: self.version |> to_string(),
      description: self.description |> to_string()
    }, opts)
  end
end
