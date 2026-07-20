defmodule PhpBB.Topics do
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

    attribute :forum_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :topic_title, :string do
      allow_nil? true
      public? true
    end

    attribute :topic_poster, :integer do
      allow_nil? true
      public? true
    end

    attribute :topic_time, :integer do
      allow_nil? true
      public? true
    end

    attribute :topic_views, :integer do
      allow_nil? true
      public? true
    end

    attribute :topic_replies, :integer do
      allow_nil? true
      public? true
    end

    attribute :topic_vote, :integer do
      allow_nil? true
      public? true
    end

    attribute :topic_type, :integer do
      allow_nil? true
      public? true
    end

    attribute :topic_first_post_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :topic_last_post_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :topic_moved_id, :integer do
      allow_nil? true
      public? true
    end
  end
end
