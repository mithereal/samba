defmodule PhpBB.Words do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_words"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :word_id,
        :word,
        :replacement
      ]
    end
  end

  attributes do
    attribute :word_id, :integer do
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :word, :string do
      allow_nil? false
      default ""
      public? true
    end

    attribute :replacement, :string do
      allow_nil? false
      default ""
      public? true
    end
  end
end
