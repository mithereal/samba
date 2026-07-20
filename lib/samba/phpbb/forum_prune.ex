defmodule PhpBB.ForumPrune do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_forum_prune"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:prune_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    integer_primary_key(:prune_id)

    relationships do
      belongs_to :forum, PhpBB.Forums do
        destination_attribute :forum_id
      end
    end

    attribute :prune_days, :integer do
      allow_nil? true
      public? true
    end

    attribute :prune_freq, :integer do
      allow_nil? true
      public? true
    end
  end
end
