defmodule Saki.Core.Self do

  [{:app, app}, {:version, version}, {:description, description} | _] = Saki.MixProject.project()

  @derive Jason.Encoder
  defstruct [
    app: app,
    version: version,
    description: description,
  ]
end
