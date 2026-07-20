defmodule PhpBB.Categories do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_categories"
    repo Samba.Repo
  end

  actions do
    default_accept [:cat_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :cat_id, :integer do
      writable? false
      generated? true
      primary_key?(true)
      allow_nil? false
    end

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
