defmodule PhpBB.VoteDesc do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_vote_desc"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :vote_id,
        :topic_id,
        :vote_text,
        :vote_start,
        :vote_length
      ]
    end
  end

  attributes do
    attribute :vote_id, :integer do
      public? true
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :topic_id, :integer do
      public? true
      default 0
      allow_nil? false
    end

    relationships do
      belongs_to :topic, PhpBB.Topics do
        destination_attribute :topic_id
        source_attribute :topic_id
        attribute_type :integer
      end
    end

    attribute :vote_text, :string do
      allow_nil? false
      public? true
    end

    attribute :vote_start, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :vote_length, :integer do
      allow_nil? false
      default 0
      public? true
    end
  end

  identities do
    identity :topic_id_phpbb_vote_desc_index, [:topic_id]
  end
end
