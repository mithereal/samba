defmodule PhpBB.AuthAccess do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_auth_access"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:group_id, :forum_id]
    defaults [:create, :read, :update, :destroy]
  end


  attributes do

    attribute :group_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :forum_id, :integer do
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

    attribute :auth_sticky, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_announce, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_vote, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_pollcreate, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_attachments, :integer do
      allow_nil? true
      public? true
    end

    attribute :auth_mod, :integer do
      allow_nil? true
      public? true
    end
  end

  index ["group_id", "forum_id"], unique: true
end
