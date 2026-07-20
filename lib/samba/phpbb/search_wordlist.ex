defmodule PhpBB.SearchWordlist do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_search_wordlist"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:word_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    integer_primary_key(:word_id)

    attribute :word_text, :string do
      allow_nil? true
      public? true
    end

    attribute :word_common, :integer do
      allow_nil? true
      public? true
    end
  end
end
