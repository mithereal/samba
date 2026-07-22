# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :mime,
  extensions: %{"json" => "application/vnd.api+json"},
  types: %{"application/vnd.api+json" => ["json"]}

config :ash_json_api,
  show_public_calculations_when_loaded?: false,
  authorize_update_destroy_with_error?: true

config :ex_cldr, default_backend: Samba.Cldr
config :cinder, default_theme: "modern"

config :ash,
  allow_forbidden_field_for_relationships_by_default?: true,
  include_embedded_source_by_default?: false,
  show_keysets_for_all_actions?: false,
  default_page_type: :keyset,
  policies: [no_filter_static_forbidden_reads?: false],
  keep_read_action_loads_when_loading?: false,
  default_actions_require_atomic?: true,
  read_action_after_action_hooks_in_order?: true,
  bulk_actions_default_to_errors?: true,
  known_types: [AshMoney.Types.Money],
  custom_types: [money: AshMoney.Types.Money]

config :spark,
  formatter: [
    remove_parens?: true,
    "Ash.Resource": [
      section_order: [
        :json_api,
        :account,
        :balance,
        :transfer,
        :authentication,
        :tokens,
        :postgres,
        :resource,
        :code_interface,
        :actions,
        :policies,
        :pub_sub,
        :preparations,
        :changes,
        :validations,
        :multitenancy,
        :attributes,
        :relationships,
        :calculations,
        :aggregates,
        :identities
      ]
    ],
    "Ash.Domain": [
      section_order: [:json_api, :resources, :policies, :authorization, :domain, :execution]
    ]
  ]

config :samba,
  ecto_repos: [Samba.Repo],
  generators: [timestamp_type: :utc_datetime],
  site_title_prefix: "",
  google_site_verification: "",
  site_default_locale: "en_US",
  site_default_mask_icon_color: "#663399",
  site_default_windows_tile_color: "#663399",
  site_themes_list: ["default"],
  site_default_description: "",
  site_default_suffix: "",
  site_default_title: "",
  site_author: "mithereal",
  site_description: "",
  site_name: "",
  facebook_app_id: "",
  twitter_site_name: "",
  twitter_site_id: "",
  twitter_site_creator: "",
  twitter_site_creator_id: "",
  ssl_endpoint_port: 4002,
  ssl_endpoint_domain_info: [{"example.com", "demo@example.com"}],
  endpoint_same_site: "Lax",
  endpoint_signing_salt: "gTm6MBR2",
  endpoint_key: "_web_key",
  endpoint_store: :cookie,
  ash_domains: [
    Samba.Ledger,
    Samba.Accounts,
    PhpBB.Domain
  ]

# Configure super admin users who are allowed to do
# special actions such as impersonating other
# users in the teams. Seeing all teams
# and more...
config :samba, super_users: ["mithereal@gmail.com"]

# Configures the endpoint
config :samba, SambaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: SambaWeb.ErrorHTML, json: SambaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Samba.PubSub,
  live_view: [signing_salt: "waEAzL0/"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :samba, Samba.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  samba: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  samba: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix_seo, json_ld_types: :all
# or mix-and-match:
config :phoenix_seo, json_ld_types: [:google, SEO.JSONLD.SearchAction]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
