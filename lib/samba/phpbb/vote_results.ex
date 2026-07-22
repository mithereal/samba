defmodule PhpBB.VoteResults do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_vote_results"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :vote_id,
        :vote_option_id,
        :vote_option_text,
        :vote_result
      ]
    end
  end

  attributes do
    relationships do
      belongs_to :vote, PhpBB.VoteDesc do
        destination_attribute :vote_id
        source_attribute :vote_id
        attribute_type :integer
      end
    end

    attribute :vote_id, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :vote_option_id, :integer do
      allow_nil? false
      default 0
      public? true
      primary_key? true
    end

    attribute :vote_option_text, :string do
      allow_nil? false
      public? true
    end

    attribute :vote_result, :integer do
      allow_nil? false
      default 0
      public? true
    end
  end
end
