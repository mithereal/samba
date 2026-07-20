defmodule PhpBB.Posts do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_posts"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:post_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:post_id)

    attribute :topic_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :forum_id, :string do
      allow_nil? true
      public? true
    end

    attribute :poster_id, :string do
      allow_nil? true
      public? true
    end

    attribute :post_time, :integer do
      allow_nil? true
      public? true
    end

    attribute :post_username, :integer do
      allow_nil? true
      public? true
    end

    attribute :poster_ip, :integer do
      allow_nil? true
      public? true
    end

    attribute :enable_bbcode, :integer do
      allow_nil? true
      public? true
    end

    attribute :enable_html, :integer do
      allow_nil? true
      public? true
    end

    attribute :enable_smilies, :integer do
      allow_nil? true
      public? true
    end

    attribute :enable_sig, :integer do
      allow_nil? true
      public? true
    end

    attribute :post_edit_time, :integer do
      allow_nil? true
      public? true
    end

    attribute :post_edit_count, :integer do
      allow_nil? true
      public? true
    end
  end
end
