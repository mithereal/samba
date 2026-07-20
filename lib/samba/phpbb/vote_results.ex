defmodule PhpBB.VoteResults do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_vote_results"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:vote_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    relationships do
      belongs_to :vote, PhpBB.VoteDesc do
        destination_attribute :vote_id
      end
    end

    attribute :vote_option_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :vote_option_text, :string do
      allow_nil? true
      public? true
    end

    attribute :vote_result, :integer do
      allow_nil? true
      public? true
    end
  end
end
