defmodule PhpBB.VoteVoters do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_vote_voters"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:vote_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:vote_id)

    attribute :vote_user_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :vote_user_ip, :string do
      allow_nil? true
      public? true
    end
  end
end
