defmodule PhpBB.Ranks do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_ranks"
    repo Samba.Repo
  end

  actions do
    default_accept [:rank_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :rank_id, :integer do
      writable? false
      generated? true
      primary_key?(true)
      allow_nil? false
    end

    attribute :rank_title, :string do
      allow_nil? true
      public? true
    end

    attribute :rank_min, :integer do
      allow_nil? true
      public? true
    end

    attribute :rank_special, :integer do
      allow_nil? true
      public? true
    end

    attribute :rank_image, :string do
      allow_nil? true
      public? true
    end
  end
end
