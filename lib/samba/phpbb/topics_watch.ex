defmodule PhpBB.TopicsWatch do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_topic_watch"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :topic_id,
        :user_id,
        :notify_status
      ]
    end
  end

  attributes do
    attribute :topic_id, :integer do
      allow_nil? false
      public? true
    end

    attribute :user_id, :integer do
      allow_nil? false
      public? true
    end

    relationships do
      belongs_to :topic, PhpBB.Topics do
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
      allow_nil? false
      public? true
    end
  end

  identities do
    identity :topic_id_phpbb_topics_watch_index, [:topic_id]
    identity :user_id_phpbb_topics_watch_index, [:user_id]
  end
end
