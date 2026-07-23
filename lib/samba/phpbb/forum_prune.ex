defmodule PhpBB.ForumPrune do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_forum_prune"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :prune_id,
        :forum_id,
        :prune_days,
        :prune_freq
      ]
    end
  end

  attributes do
    attribute :prune_id, :integer do
      public? true
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :forum_id, :integer do
      public? true
      generated? false
      primary_key? true
      allow_nil? false
    end

    relationships do
      belongs_to :forum, PhpBB.Forums do
        destination_attribute :forum_id
        source_attribute :forum_id
        attribute_type :integer
      end
    end

    attribute :prune_days, :integer do
      allow_nil? false
      public? true
    end

    attribute :prune_freq, :integer do
      allow_nil? false
      public? true
    end
  end
end
