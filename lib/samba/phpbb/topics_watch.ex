defmodule PhpBB.TopicsWatch do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_topics"
    repo Samba.Repo
  end

  actions do
    default_accept [:topic_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :topic_id, :string do
      allow_nil? true
      public? true
    end

    attribute :user_id, :string do
      allow_nil? true
      public? true
    end

    relationships do
      belongs_to :topic, PhpBB.Topic do
        destination_attribute :topic_id
        source_attribute :topic_id
        attribute_type :integer
      end

      belongs_to :user, PhpBB.Users do
        destination_attribute :user_id
        source_attribute :user_id
        attribute_type :integer
      end
    end

    attribute :notify_status, :string do
      allow_nil? true
      public? true
    end
  end

  identities do
    identity :unique_name, [:topic_id]
    identity :unique_name, [:user_id]
  end
end
