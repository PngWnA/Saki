defmodule Saki.Application do

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      {Saki.Core.HttpServer,
        [
          port: Application.get_env(:saki, Saki.Core.HttpServer)[:port] || 31413
        ]
      },
      {Saki.Core.CronScheduler, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Saki.Supervisor)
  end

end
