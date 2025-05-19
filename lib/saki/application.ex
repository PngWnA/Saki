defmodule Saki.Application do

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    # Run migrations on startup for in-memory database
    run_migrations()

    children = [
      # Database connection
      Saki.Repo,

      # Job processing
      {Oban, Application.fetch_env!(:saki, Oban)},

      # HTTP Server
      {Plug.Cowboy, scheme: :http, plug: Saki.Core.HTTPServer, options: [port: 31413]},

      # Job dispatcher
      Saki.Core.Dispatcher,
    ]

    # Initialize the CronScheduler
    Saki.Core.CronScheduler.init()

    opts = [strategy: :one_for_one, name: Saki.Core.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp run_migrations do
    Logger.info("Running migrations for in-memory database")

    # Start Repo temporarily for migrations
    {:ok, _} = Saki.Repo.start_link([])

    # Run Oban migrations
    Ecto.Migrator.run(Saki.Repo, :up, all: true)

    # Stop the repo - it will be restarted properly by the supervisor
    Saki.Repo.stop()

    Logger.info("Migrations complete")
  end
end
