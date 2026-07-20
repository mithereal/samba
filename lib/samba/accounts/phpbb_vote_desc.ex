defmodule PhpBB.VoteDesc do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_vote_desc"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:vote_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:vote_id)

    attribute :topic_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :vote_text, :string do
      allow_nil? true
      public? true
    end

    attribute :vote_start, :integer do
      allow_nil? true
      public? true
    end

    attribute :vote_length, :integer do
      allow_nil? true
      public? true
    end
  end
end
