defmodule Saki.Application do

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = []

    opts = [strategy: :one_for_one, name: Saki.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
