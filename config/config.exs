import Config

config :logger,
  level: :info,
  backends: [:console]

# Configure Ecto with in-memory SQLite
config :saki, ecto_repos: [Saki.Repo]

config :saki, Saki.Repo,
  database: ":memory:",
  pool_size: 5

# Configure Oban for job processing
config :saki, Oban,
  repo: Saki.Repo,
  engine: Oban.Engines.Lite,
  plugins: [
    {Oban.Plugins.Cron,
      crontab: [
        # Run clock worker every minute
        {"* * * * *", Saki.Core.CronScheduler, :run_clock_task}
      ]
    }
  ],
  queues: [default: 10]

config :saki, Saki.Core.CronScheduler,
  timezone: "Asia/Seoul",
  global: true,
  debug_logging: true
