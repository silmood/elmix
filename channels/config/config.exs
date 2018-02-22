# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :channels,
  namespace: Elmix.Channels,
  ecto_repos: [Elmix.Channels.Repo]

# Configures the endpoint
config :channels, Elmix.ChannelsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nAA7ockEWeS3CXbxNqNiDdd+BI3OE4t9Ciw6Xy+m6KvMnD8bqMsjX1P4edy8qbsd",
  render_errors: [view: Elmix.ChannelsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Elmix.Channels.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
