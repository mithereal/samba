defmodule PhpBB.Ranks do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_ranks"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:rank_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:rank_id)

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
