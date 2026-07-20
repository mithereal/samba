defmodule PhpBB.SearchWordmatch do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_search_wordmatch"
    repo Samba.Repo
  end

  actions do
    default_accept [:post_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    relationships do
      belongs_to :post, PhpBB.Posts do
        destination_attribute :post_id
      end

      belongs_to :word, PhpBB.SearchWordlist do
        destination_attribute :word_id
      end
    end

    attribute :title_match, :string do
      allow_nil? true
      public? true
    end
  end
end
