defmodule PhpBB.Topics do
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
    attribute :topic_id, :integer do
      writable? false
      generated? true
      primary_key?(true)
      allow_nil? false
    end

    relationships do
      belongs_to :forum, PhpBB.Forums do
        destination_attribute :forum_id
      end

      belongs_to :poster, PhpBB.Users do
        destination_attribute :topic_poster
      end

      belongs_to :first_post, PhpBB.Posts do
        destination_attribute :topic_first_post_id
      end

      belongs_to :last_post, PhpBB.Posts do
        destination_attribute :topic_last_post_id
      end

      belongs_to :moved, PhpBB.Topics do
        destination_attribute :topic_moved_id
      end

      belongs_to :vote, PhpBB.VoteDesc do
        destination_attribute :topic_vote
      end
    end

    attribute :topic_title, :string do
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

    attribute :topic_type, :integer do
      allow_nil? true
      public? true
    end
  end
end
