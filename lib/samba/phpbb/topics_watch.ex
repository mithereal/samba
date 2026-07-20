defmodule PhpBB.TopicsWatch do
  use Ash.Resource,
    domain: PhpBB,
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
    relationships do
      belongs_to :topic, PhpBB.Topic do
        destination_attribute :topic_id
      end

      belongs_to :user, PhpBB.Users do
        destination_attribute :user_id
      end
    end

    attribute :notify_status, :string do
      allow_nil? true
      public? true
    end
  end
end
