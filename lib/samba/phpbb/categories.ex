defmodule PhpBB.Categories do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_categories"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :cat_id,
        :cat_title,
        :cat_order
      ]
    end
  end

  attributes do
    attribute :cat_id, :integer do
      generated? true
      primary_key? true
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

    relationships do
      has_many :forums, PhpBB.Forums do
        destination_attribute :cat_id
        source_attribute :cat_id
        default_sort [forum_order: :asc]
      end
    end
  end
end
