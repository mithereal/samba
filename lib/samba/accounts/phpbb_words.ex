defmodule PhpBB.Words do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_words"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:word_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:word_id)

    attribute :word, :string do
      allow_nil? true
      public? true
    end

    attribute :replacement, :string do
      allow_nil? true
      public? true
    end
  end
end
