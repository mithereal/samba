defmodule PhpBB.Forums do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_forums"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true

      accept [
        :forum_id,
        :cat_id,
        :forum_last_post_id,
        :forum_name,
        :forum_desc,
        :forum_status,
        :forum_order,
        :prune_enable,
        :prune_next,
        :auth_view,
        :auth_read,
        :auth_post,
        :auth_reply,
        :auth_edit,
        :auth_delete,
        :auth_announce,
        :auth_sticky,
        :auth_pollcreate,
        :auth_vote,
        :auth_attachments
      ]
    end

    update :update do
      primary? true

      accept [
        :forum_id,
        :cat_id,
        :forum_last_post_id,
        :forum_name,
        :forum_desc,
        :forum_status,
        :forum_order,
        :prune_enable,
        :prune_next,
        :auth_view,
        :auth_read,
        :auth_post,
        :auth_reply,
        :auth_edit,
        :auth_delete,
        :auth_announce,
        :auth_sticky,
        :auth_pollcreate,
        :auth_vote,
        :auth_attachments
      ]
    end
  end

  attributes do
    attribute :forum_id, :integer do
      public? true
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :forum_last_post_id, :integer do
      public? true
      allow_nil? true
    end

    attribute :cat_id, :integer do
      public? true
      allow_nil? false
    end

    relationships do
      belongs_to :category, PhpBB.Categories do
        destination_attribute :cat_id
        source_attribute :cat_id
        attribute_type :integer
      end

      belongs_to :last_post, PhpBB.Posts do
        source_attribute :forum_last_post_id
        destination_attribute :post_id
        attribute_type :integer
      end

      has_many :forum_posts, PhpBB.Posts do
        destination_attribute :post_id
        source_attribute :forum_id
      end

      has_many :forum_topics, PhpBB.Topics do
        destination_attribute :topic_id
        source_attribute :forum_id
      end
    end

    attribute :forum_name, :string do
      allow_nil? false
      public? true
    end

    attribute :forum_desc, :string do
      allow_nil? false
      public? true
    end

    attribute :forum_status, :boolean do
      public? true
      default false
    end

    attribute :forum_order, :integer do
      public? true
      default 1
    end

    attribute :prune_enable, :boolean do
      public? true
      default false
    end

    attribute :prune_next, :boolean do
      allow_nil? false
      public? true
      default false
    end

    attribute :auth_view, :boolean do
      public? true
      default true
    end

    attribute :auth_read, :boolean do
      public? true
      default true
    end

    attribute :auth_post, :boolean do
      public? true
      default false
    end

    attribute :auth_reply, :boolean do
      public? true
      default false
    end

    attribute :auth_edit, :boolean do
      public? true
      default false
    end

    attribute :auth_delete, :boolean do
      public? true
      default false
    end

    attribute :auth_announce, :boolean do
      public? true
      default false
    end

    attribute :auth_sticky, :boolean do
      public? true
      default false
    end

    attribute :auth_pollcreate, :boolean do
      public? true
      default false
    end

    attribute :auth_vote, :boolean do
      public? true
      default false
    end

    attribute :auth_attachments, :boolean do
      public? true
      default false
    end
  end

  identities do
    identity :forum_id_phpbb_forums_index, [:forum_id]
  end
end
