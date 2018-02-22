# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :elmix,
  ecto_repos: [Elmix.Repo]

# Configures the endpoint
config :elmix, ElmixWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Y7fLJI9GYmKJsKoPEg1S8OW6PXK6XsgJ0ZVkQ/kIvJxvQez4+tW+uiUtWr2720GB",
  render_errors: [view: ElmixWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Elmix.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
