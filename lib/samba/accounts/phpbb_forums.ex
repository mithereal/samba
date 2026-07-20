defmodule PhpBB.Forums do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_forums"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:forum_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:forum_id)

    attribute :cat_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :forum_name, :string do
      allow_nil? true
      public? true
    end

    attribute :forum_desc, :string do
      allow_nil? true
      public? true
    end

    attribute :forum_status, :integer do
      allow_nil? true
      public? true
    end

    attribute :forum_order, :integer do
      allow_nil? true
      public? true
    end

    attribute :forum_posts, :integer do
      allow_nil? true
      public? true
    end

    attribute :forum_topics, :integer do
      allow_nil? true
      public? true
    end

    attribute :forum_last_post_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :prune_enable, :integer do
      allow_nil? true
      public? true
    end

    attribute :prune_next, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_view, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_read, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_post, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_reply, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_edit, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_delete, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_announce, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_sticky, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_pollcreate, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_vote, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_attachments, :integer do
      allow_nil? true
      public? true
    end
  end
  
end
