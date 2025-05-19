defmodule Saki.Core.Self do

  @derive Jason.Encoder
  defstruct [:app, :version, :description]

  def info do
    environments = Application.get_all_env(:saki)

    %__MODULE__{
      app: :saki,
      version: Application.spec(:saki, :vsn) |> to_string(),
      description: environments[:description] || "Saki-Chan"
    }
  end

end
