defmodule Saki.Application do

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [

      Saki.Core.TaskRegistry,

      {Saki.Core.Dispatcher, []},
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Saki.Core.HttpServer,
        options: [
          port: Application.get_env(:saki, Saki.Core.HttpServer)[:port] || 31413
        ]
      ),

      #{Saki.Core.CronScheduler, []}
    ]

    opts = [strategy: :one_for_one, name: Saki.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
