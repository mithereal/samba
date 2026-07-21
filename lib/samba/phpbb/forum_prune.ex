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
    default_accept [:prune_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :prune_id, :integer do
      writable? false
      generated? true
      primary_key? true
      allow_nil? false
    end

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
