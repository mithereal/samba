defmodule PhpBB.PostsText do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_posts_text"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:post_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:post_id)

    attribute :bbcode_uid, :integer do
      allow_nil? true
      public? true
    end

    attribute :post_subject, :string do
      allow_nil? true
      public? true
    end

    attribute :post_text, :string do
      allow_nil? true
      public? true
    end
  end
end
