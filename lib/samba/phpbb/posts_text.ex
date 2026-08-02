defmodule PhpBB.PostsText do
  use Ash.Resource,
    domain: PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_posts_text"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :post_id,
        :bbcode_uid,
        :post_subject,
        :post_text
      ]
    end
  end

  attributes do
    attribute :post_id, :integer do
      public? true
      primary_key? true
      allow_nil? false
    end

    attribute :bbcode_uid, :string do
      public? true
      default ""
      allow_nil? false
    end

    attribute :post_subject, :string do
      public? true
      default ""
      allow_nil? true
    end

    attribute :post_text, :string do
      public? true
      allow_nil? true
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
