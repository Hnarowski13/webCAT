defmodule WebCAT.Mixfile do
  use Mix.Project

  def project do
    [
      app: :webcat,
      version: "0.1.0",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {WebCAT, []},
      extra_applications: ~w(logger runtime_tools)a
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ~w(lib test/support)
  defp elixirc_paths(_), do: ~w(lib)

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:anaphora, "~> 0.1.2"},
      {:bamboo, "~> 1.0"},
      {:bodyguard, "~> 2.2"},
      {:comeonin, "~> 4.0"},
      {:cors_plug, "~> 1.5"},
      {:cowboy, "~> 1.0"},
      {:distillery, "~> 2.0", runtime: false},
      {:dialyxir, git: "https://github.com/jeremyjh/dialyxir.git", only: [:dev], runtime: false},
      {:ecto, "~> 2.2.10"},
      {:faker, "~> 0.10", exclude: :prod},
      {:ex_machina, "~> 2.2", exclude: :prod},
      {:gettext, "~> 0.16"},
      {:guardian, "~> 1.0"},
      {:jason, ">= 1.0.0"},
      {:pbkdf2_elixir, "~> 0.12"},
      {:phoenix, "~> 1.3.2"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:postgrex, "~> 0.13.5"},
      {:proper_case, "~> 1.0.2"},
      {:timex, "~> 3.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end