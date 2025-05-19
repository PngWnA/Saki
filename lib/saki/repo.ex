defmodule Saki.Repo do
  use Ecto.Repo,
    otp_app: :saki,
    adapter: Ecto.Adapters.SQLite3
end
