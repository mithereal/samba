defmodule PhpBB.AuthAccess do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_auth_access"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :group_id,
        :forum_id,
        :auth_view,
        :auth_read,
        :auth_post,
        :auth_reply,
        :auth_edit,
        :auth_delete,
        :auth_sticky,
        :auth_announce,
        :auth_vote,
        :auth_pollcreate,
        :auth_attachments,
        :auth_mod
      ]
    end
  end

  attributes do
    attribute :group_id, :integer do
      public? true
      allow_nil? false
      primary_key? true
      default 0
    end

    attribute :forum_id, :integer do
      public? true
      allow_nil? false
      primary_key? true
      default 0
    end

    relationships do
      belongs_to :group, PhpBB.Groups do
        destination_attribute :group_id
        source_attribute :group_id
        attribute_type :integer
      end

      belongs_to :forum, PhpBB.Forums do
        destination_attribute :forum_id
        source_attribute :forum_id
        attribute_type :integer
      end
    end

    attribute :auth_view, :integer do
      allow_nil? false
      public? true
      default 0
    end

    attribute :auth_read, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 0
      public? true
    end

    attribute :auth_post, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 0
      public? true
    end

    attribute :auth_reply, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 0
      public? true
    end

    attribute :auth_edit, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 0
      public? true
    end

    attribute :auth_delete, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 0
      public? true
    end

    attribute :auth_sticky, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 0
      public? true
    end

    attribute :auth_announce, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 0
      public? true
    end

    attribute :auth_vote, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 0
      public? true
    end

    attribute :auth_pollcreate, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 0
      public? true
    end

    attribute :auth_attachments, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 0
      public? true
    end

    attribute :auth_mod, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 0
      public? true
    end
  end
end
