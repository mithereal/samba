defmodule PhpBB.Config do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_config"
    repo Samba.Repo
  end

  actions do
    default_accept [:config_name, :config_value]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :config_name, :string do
      allow_nil? true
      public? true
    end

    attribute :config_value, :integer do
      allow_nil? true
      public? true
    end
  end

  identities do
    identity :unique_name, [:config_name]
  end
end
