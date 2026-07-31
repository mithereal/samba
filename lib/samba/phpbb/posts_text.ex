defmodule PhpBB.PostsText do
  use Ash.Resource,
      domain: Elixir.PhpBB.Domain,
      data_layer: AshPostgres.DataLayer,
      notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_posts_text"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true

      accept [
        :post_id,
        :topic_id,
        :forum_id,
        :poster_id,
        :post_subject,
        :post_text,
        :bbcode_uid
      ]
    end

    update :update do
      primary? true

      accept [
        :post_subject,
        :post_text,
        :bbcode_uid,
        :post_checksum,
        :post_edit_reason
      ]
    end
  end

  attributes do
    attribute :post_id, :integer do
      public? true
      primary_key? true
      allow_nil? false
    end

    attribute :topic_id, :integer do
      public? true
      allow_nil? false
      default 0
    end

    attribute :forum_id, :integer do
      public? true
      allow_nil? false
      default 0
    end

    attribute :poster_id, :integer do
      public? true
      allow_nil? false
      default 0
    end

    attribute :post_subject, :string do
      public? true
      allow_nil? true
    end

    attribute :post_text, :string do
      public? true
      allow_nil? false
    end

    attribute :bbcode_uid, :string do
      public? true
      allow_nil? false
      default ""
    end

    attribute :post_checksum, :string do
      public? true
    end

    attribute :post_edit_reason, :string do
      public? true
    end
  end

  relationships do
    belongs_to :post, PhpBB.Posts do
      destination_attribute :post_id
      source_attribute :post_id
      attribute_type :integer
    end
  end
end
