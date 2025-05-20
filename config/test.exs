import Config

# Configure the HTTP server
config :saki, Saki.Core.HttpServer,
  port: 31413

# Enable hot reloading
config :saki, :reload_app_on_every_request, true
