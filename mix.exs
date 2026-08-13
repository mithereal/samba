defmodule Samba.MixProject do
  use Mix.Project

  def project do
    [
      app: :samba,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_paths: ["test", "lib"],
      compilers: [:phoenix_live_view, :seo_jsonld] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader],
      consolidate_protocols: Mix.env() != :dev
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Samba.Application, []},
      extra_applications: [:logger, :runtime_tools, :debugger]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:open_api_spex, "~> 3.0"},
      {:decimal, "~> 3.0", override: true},
      {:ash_json_api, "~> 1.0"},
      {:rename_project, "~> 0.1"},
      {:ex_money_sql, "~> 1.0"},
      {:ex_cldr, "~> 2.0"},
      {:ash_money, "~> 0.2"},
      {:ash_double_entry, "~> 1.0"},
      {:nimble_csv, "~> 1.0"},
      {:cinder, "~> 0.7"},
      {:bcrypt_elixir, "~> 3.0"},
      {:picosat_elixir, "~> 0.2"},
      {:sourceror, "~> 1.8", only: [:dev, :test]},
      {:live_debugger, "~> 0.4", only: [:dev]},
      {:ash_authentication_phoenix, "~> 2.0"},
      {:ash_authentication, "~> 4.0"},
      {:ash_postgres, "~> 2.0"},
      {:ash_phoenix, "~> 2.0"},
      {:ash, "~> 3.29", override: true},
      {:igniter, "~> 0.6", only: [:dev, :test]},
      {:phoenix, "~> 1.8.1"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13", override: true},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.2"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.16"},
      {:req, "~> 0.5"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},
      {:mishka_chelekom, "~> 0.0.9", only: :dev},
      {:ash_pagify, "~> 1.5"},
      {:ash_archival, "~> 2.0"},
      {:phoenix_seo, "~> 0.3.1"},
      {:floki, "~> 0.35", override: true},
      {:faker, "~> 0.19.0"},
      {:makeup, "~> 1.2.2", override: true},
      {:ckeditor5_phoenix, "~> 1.28.2"},
      {:ash_ops, "~> 0.2.4"},
      {:nimble_parsec, "~> 1.4"},
      {:ex_bbcode, github: "/mithereal/ex_bbcode"},
      {:abatap, "~> 0.2.0"},
      {:phoenix_copy, ">= 0.0.0"},
      {:adept_svg, ">= 0.0.0"},
      {:image, "~> 0.54.1"},
      {:etag_plug, "~> 1.0"},
      {:plug_cache_control, "~> 1.1.0", github: "tanguilp/plug_cache_control"},
      {:phoenix_bakery, "~> 0.1.0", runtime: false},
      {:reverse_proxy_plug, "~> 3.0"},
      {:thumbp, ">= 0.0.0"},
      {:unzip, ">= 0.0.0"},
      {:live_select, ">= 0.0.0"},
      {:location, github: "data-twister/location"},
      {:altcha, ">= 0.0.0"},
      {:plug_attack, ">= 0.0.0"},
      {:maybe, ">= 0.0.0"},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:sobelow, ">= 0.0.0"},
      {:safeurl, ">= 0.0.0"},
      {:recon, ">= 0.0.0"},
      {:ex_rated, ">= 0.0.0"},
      {:ex_cldr_calendars, ">= 0.0.0"},
      {:ex_cldr_units, ">= 0.0.0"},
      {:ex_cldr_dates_times, ">= 0.0.0"},
      {:ex_cldr_numbers, ">= 0.0.0"},
      {:ex_cldr_territories, ">= 0.0.0"},
      {:prom_ex, ">= 0.0.0"},
      {:remote_ip, ">= 0.0.0"},
      {:hammer, ">= 0.0.0"},
      {:iptrie, ">= 0.0.0"},
      {:premailex, "~> 0.3.0"},
      {:flag_icons, "~> 0.1.0"},
      {:shift, "~> 0.2.1"},
      {:spaceboy, "~> 0.4.0"},
      {:x509, "~> 0.8"},
      {:thousand_island, "~> 1.4"}
      # {:calendar_component, "~> 0.2.1", override: true},
      # {:phoenix_live_calendar, "~> 0.5.0"}
      # {:phoenix_email, "~> 0.1.2"}
      # {:live_ex_webrtc, "~> 0.8.0"},
      # {:phx_image, "~> 0.1.0"}
      # {:image_components, "~> 0.1.1"}
      # {:athanor, "~> 0.1.0-beta.10"}
      # {:ex_money_input, "~> 0.3.0"}
      # {:cinder, "~> 0.17.0"}
      # {:mbta_metro, "~> 1.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ash.setup", "assets.setup", "assets.build", "run priv/repo/seeds.exs"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ash.setup --quiet", "test"],
      "assets.setup": [
        "tailwind.install --if-missing",
        "esbuild.install --if-missing",
        "ckeditor5.install"
      ],
      "assets.build": ["compile", "tailwind Samba", "esbuild Samba"],
      "assets.deploy": [
        "tailwind Samba --minify",
        "esbuild Samba --minify",
        "phx.digest"
      ],
      precommit: ["compile --warning-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end
end
