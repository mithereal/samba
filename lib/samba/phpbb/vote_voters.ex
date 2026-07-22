defmodule PhpBB.VoteVoters do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_vote_voters"
    repo Samba.Repo
  end

  actions do
    default_accept [:vote_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :vote_id, :integer do
      allow_nil? false
      default 0
      public? true
      primary_key? true
    end

    attribute :vote_user_id, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :vote_user_ip, :string do
      allow_nil? false
      public? true
    end

    relationships do
      belongs_to :user, PhpBB.Users do
        destination_attribute :vote_user_id
        source_attribute :vote_user_id
        attribute_type :integer
      end

      belongs_to :vote, PhpBB.VoteDesc do
        destination_attribute :vote_id
        source_attribute :vote_id
        attribute_type :integer
      end
    end
  end

  identities do
    identity :unique_name, [:vote_user_id]
    identity :unique_name, [:vote_user_ip]
  end
end
