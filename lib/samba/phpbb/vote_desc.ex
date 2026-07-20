defmodule PhpBB.VoteDesc do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_vote_desc"
    repo Samba.Repo
  end

  actions do
    default_accept [:vote_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :vote_id, :integer do
      writable? false
      generated? true
      primary_key?(true)
      allow_nil? false
    end

    relationships do
      belongs_to :topic, PhpBB.Topics do
        destination_attribute :topic_id
      end
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
