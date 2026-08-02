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
    defaults [:read, :destroy]

    create :create do
      accept [:cat_title, :cat_order]
    end

    update :update do
      accept [:cat_title, :cat_order]
    end
  end

  attributes do
    integer_primary_key :cat_id, source: :cat_id
    attribute :cat_title, :string, allow_nil?: false
    attribute :cat_order, :integer, allow_nil?: false
  end

  relationships do
    has_many :forums, PhpBB.Forums do
      destination_attribute :cat_id
      source_attribute :cat_id
      default_sort forum_order: :asc
    end
  end
end
