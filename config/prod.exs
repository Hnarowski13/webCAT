use Mix.Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
#
# You should also configure the url host to something
# meaningful, we use this information when generating URLs.
#
# Finally, we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.

# Do not print debug messages in production
config :logger, level: :info

config :cors_plug,
  origin: ["*"],
  max_age: 86_400,
  methods: ["GET", "POST", "PATCH", "DELETE"]
