defmodule Saki.Application do

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # HTTP Server
      {Plug.Cowboy, scheme: :http, plug: Saki.Core.HTTPServer, options: [port: 8080]},

      # Job dispatcher
      Saki.Core.Dispatcher,
    ]

    opts = [strategy: :one_for_one, name: Saki.Core.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
