defmodule PhpBB.SearchWordmatch do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_search_wordmatch"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:post_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do

    attribute :post_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :word_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :title_match, :string do
      allow_nil? true
      public? true
    end
  end
end
