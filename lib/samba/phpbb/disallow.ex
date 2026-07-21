defmodule PhpBB.Disallow do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_disallow"
    repo Samba.Repo
  end

  actions do
    default_accept [:disallow_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :disallow_id, :integer do
      writable? false
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :disallow_username, :integer do
      allow_nil? true
      public? true
    end
  end
end
