defmodule PhpBB.Disallow do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_disallow"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:disallow_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:disallow_id)

    attribute :disallow_username, :integer do
      allow_nil? true
      public? true
    end
  end
end
