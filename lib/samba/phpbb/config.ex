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
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      accept [
        :config_name,
        :config_value
      ]
    end
  end

  attributes do
    attribute :config_name, :string do
      allow_nil? false
      public? true
      primary_key? true
    end

    attribute :config_value, :integer do
      allow_nil? false
      public? true
    end
  end
end
