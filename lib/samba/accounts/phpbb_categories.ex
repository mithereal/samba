defmodule PhpBB.Forums do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_categories"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:cat_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:cat_id)

    attribute :cat_title, :string do
      allow_nil? true
      public? true
    end

    attribute :cat_order, :integer do
      allow_nil? true
      public? true
    end
  end
end
