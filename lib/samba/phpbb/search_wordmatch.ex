defmodule PhpBB.SearchWordmatch do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
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
    attribute :word_id, :integer do
      allow_nil? false
      default 0
    end

    attribute :post_id, :integer do
      allow_nil? false
      default 0
    end

    relationships do
      belongs_to :post, PhpBB.Posts do
        destination_attribute :post_id
        source_attribute :post_id
        attribute_type :integer
      end

      belongs_to :word, PhpBB.SearchWordlist do
        destination_attribute :word_id
        source_attribute :word_id
        attribute_type :integer
      end
    end

    attribute :title_match, :string do
      constraints min_length: 0, max_length: 32767
      default "0"
      allow_nil? false
      public? true
    end
  end

  identities do
    identity :unique_name, [:word_id]
    identity :unique_name, [:post_id]
  end
end
