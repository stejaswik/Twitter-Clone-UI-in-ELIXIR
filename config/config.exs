# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :phoenixproject,
  ecto_repos: [Phoenixproject.Repo]

# Configures the endpoint
config :phoenixproject, PhoenixprojectWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HSHIc0hGG+if/RpkZii9ZcGVtDGhLS39HV7FSt4z+u+k14uiSw0VpLuca1gKq6Pg",
  render_errors: [view: PhoenixprojectWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Phoenixproject.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
