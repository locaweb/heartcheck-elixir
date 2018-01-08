use Mix.Config

config :heartcheck, :config, "http://localhost"

# You can configure for your application as:
#
#     config :heartcheck, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:heartcheck, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
