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
    relationships do
      belongs_to :post, PhpBB.Posts do
        destination_attribute :post_id
        source_attribute :post_id
      end
    end

    attribute :post_id, :integer do
      allow_nil? false
      public? true
      default 0
      primary_key? true
    end

    attribute :bbcode_uid, :string do
      allow_nil? false
      public? true
      default ""
    end

    attribute :post_subject, :string do
      allow_nil? false
      public? true
    end

    attribute :post_text, :string do
      allow_nil? false
      public? true
    end
  end
end
