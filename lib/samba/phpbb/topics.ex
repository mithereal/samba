defmodule PhpBB.Topics do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_topics"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :topic_id,
        :forum_id,
        :topic_poster,
        :first_post_id,
        :last_post_id,
        :topic_moved_id,
        :topic_title,
        :topic_time,
        :topic_views,
        :topic_replies,
        :topic_status,
        :topic_vote,
        :topic_type
      ]
    end
  end

  attributes do
    attribute :topic_id, :integer do
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :forum_id, :integer do
      default 0
      allow_nil? false
    end

    attribute :topic_poster, :integer do
      default 0
      allow_nil? false
    end

    attribute :first_post_id, :integer do
      default 0
      allow_nil? false
    end

    attribute :last_post_id, :integer do
      default 0
      allow_nil? false
    end

    attribute :topic_moved_id, :integer do
      default 0
      allow_nil? false
    end

    relationships do
      belongs_to :forum, PhpBB.Forums do
        destination_attribute :forum_id
        source_attribute :forum_id
        attribute_type :integer
      end

      belongs_to :poster, PhpBB.Users do
        destination_attribute :user_id
        source_attribute :topic_poster
        attribute_type :integer
      end

      belongs_to :first_post, PhpBB.Posts do
        destination_attribute :post_id
        source_attribute :topic_first_post_id
        attribute_type :integer
      end

      belongs_to :last_post, PhpBB.Posts do
        destination_attribute :post_id
        source_attribute :topic_last_post_id
        attribute_type :integer
      end

      belongs_to :moved, PhpBB.Topics do
        destination_attribute :topic_moved_id
        source_attribute :topic_moved_id
        attribute_type :integer
      end
    end

    attribute :topic_title, :string do
      allow_nil? false
      default ""
      public? true
    end

    attribute :topic_time, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :topic_views, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :topic_replies, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :topic_status, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true
    end

    attribute :topic_vote, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true
    end

    attribute :topic_type, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true
    end
  end

  identities do
    identity :forum_id_phpbb_topics_index, [:forum_id]
    identity :topic_moved_id_phpbb_topics_index, [:topic_moved_id]
    identity :topic_first_post_id_phpbb_topics_index, [:topic_first_post_id]
    identity :topic_last_post_id_phpbb_topics_index, [:topic_last_post_id]
    identity :topic_status_phpbb_topics_index, [:topic_status]
    identity :topic_type_phpbb_topics_index, [:topic_type]
  end
end
