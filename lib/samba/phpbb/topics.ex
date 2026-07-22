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
    default_accept [:topic_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :topic_id, :integer do
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :form_id, :integer do
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
        source_attribute :topic_poster
        destination_attribute :topic_poster
        attribute_type :integer
      end

      belongs_to :first_post, PhpBB.Posts do
        destination_attribute :topic_first_post_id
        source_attribute :topic_first_post_id
        attribute_type :integer
      end

      belongs_to :last_post, PhpBB.Posts do
        destination_attribute :topic_last_post_id
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
    identity :unique_name, [:forum_id]
    identity :unique_name, [:topic_moved_id]
    identity :unique_name, [:topic_first_post_id]
    identity :unique_name, [:topic_last_post_id]
    identity :unique_name, [:topic_status]
    identity :unique_name, [:topic_type]
  end
end
