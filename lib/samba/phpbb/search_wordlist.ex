defmodule PhpBB.SearchWordlist do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_search_wordlist"
    repo Samba.Repo
  end

  actions do
    default_accept [:word_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :word_id, :integer do
      writable? false
      generated? true
      primary_key? true
      allow_nil? false
    end

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
