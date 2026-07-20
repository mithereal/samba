defmodule PhpBB.TopicsWatch do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_topics"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:topic_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:topic_id)

    attribute :user_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :notify_status, :string do
      allow_nil? true
      public? true
    end
  end
end
