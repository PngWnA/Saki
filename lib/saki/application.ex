defmodule Saki.Application do

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Job dispatcher
      Saki.Core.Dispatcher,

      # Cron Executor
      Saki.Core.CronExecutor,

      # HTTP Server
      {Plug.Cowboy, scheme: :http, plug: Saki.Core.HTTPServer, options: [port: 8080]},
    ]

    opts = [strategy: :one_for_one, name: Saki.Core.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
