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
    default_accept [:forum_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :forum_id, :integer do
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :forum_last_post_id, :integer do
      allow_nil? false
    end

    attribute :cat_id, :integer do
      allow_nil? false
    end

    relationships do
      belongs_to :category, PhpBB.Categories do
        destination_attribute :cat_id
        source_attribute :cat_id
        attribute_type :integer
      end

      belongs_to :lastpost, PhpBB.Posts do
        destination_attribute :post_id
        source_attribute :forum_last_post_id
        attribute_type :integer
      end

      has_many :posts, PhpBB.Posts do
        destination_attribute :post_id
        source_attribute :forum_id
      end

      has_many :topics, PhpBB.Topics do
        destination_attribute :topic_id
        source_attribute :forum_id
      end
    end

    attribute :forum_name, :string do
      allow_nil? false
      public? true
    end

    attribute :forum_desc, :string do
      allow_nil? true
      public? true
    end

    attribute :forum_status, :integer do
      allow_nil? false
      public? true
      constraints min: -32768, max: 32767
      default 0
    end

    attribute :forum_order, :integer do
      allow_nil? false
      public? true
      default 1
    end

    attribute :prune_enable, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 0
    end

    attribute :prune_next, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_view, :integer do
      allow_nil? false
      public? true
      constraints min: -32768, max: 32767
      default 0
    end

    attribute :auth_read, :integer do
      allow_nil? false
      public? true
      constraints min: -32768, max: 32767
      default 0
    end

    attribute :auth_post, :integer do
      allow_nil? false
      public? true
      constraints min: -32768, max: 32767
      default 0
    end

    attribute :auth_reply, :integer do
      allow_nil? false
      public? true
      constraints min: -32768, max: 32767
      default 0
    end

    attribute :auth_edit, :integer do
      allow_nil? false
      public? true
      constraints min: -32768, max: 32767
      default 0
    end

    attribute :auth_delete, :integer do
      allow_nil? false
      public? true
      constraints min: -32768, max: 32767
      default 0
    end

    attribute :auth_announce, :integer do
      allow_nil? false
      public? true
      constraints min: -32768, max: 32767
      default 0
    end

    attribute :auth_sticky, :integer do
      allow_nil? false
      public? true
      constraints min: -32768, max: 32767
      default 0
    end

    attribute :auth_pollcreate, :integer do
      allow_nil? false
      public? true
      constraints min: -32768, max: 32767
      default 0
    end

    attribute :auth_vote, :integer do
      allow_nil? false
      public? true
      constraints min: -32768, max: 32767
      default 0
    end

    attribute :auth_attachments, :integer do
      allow_nil? false
      public? true
      constraints min: -32768, max: 32767
      default 0
    end
  end

  identities do
    identity :unique_name, [:cat_id]
    identity :unique_name, [:forum_order]
    identity :unique_name, [:forum_last_post_id]
  end
end
