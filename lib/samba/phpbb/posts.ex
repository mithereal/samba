defmodule PhpBB.Posts do
  use Ash.Resource,
    domain: PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_posts"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :topic_id,
        :forum_id,
        :poster_id,
        :post_time,
        :post_username,
        :poster_ip,
        :enable_bbcode,
        :enable_html,
        :enable_smilies,
        :enable_sig,
        :post_edit_time,
        :post_edit_count
      ]
    end
  end

  attributes do
    attribute :post_id, :integer do
      public? true
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :topic_id, :integer do
      public? true
      allow_nil? false
    end

    attribute :forum_id, :integer do
      public? true
      allow_nil? false
    end

    attribute :poster_id, :integer do
      public? true
      allow_nil? false
    end

    attribute :post_time, :integer do
      public? true
      allow_nil? false
    end

    attribute :post_username, :string do
      public? true
      default " "
      allow_nil? true
    end

    attribute :poster_ip, :string do
      public? true
      default "127.0.0.1"
      allow_nil? false
    end

    attribute :enable_bbcode, :integer do
      public? true
      default 1
      allow_nil? false
    end

    attribute :enable_html, :integer do
      public? true
      default 0
      allow_nil? false
    end

    attribute :enable_smilies, :integer do
      public? true
      default 1
      allow_nil? false
    end

    attribute :enable_sig, :integer do
      public? true
      default 1
      allow_nil? false
    end

    attribute :post_edit_time, :integer do
      public? true
      default 0
      allow_nil? true
    end

    attribute :post_edit_count, :integer do
      public? true
      default 0
      allow_nil? false
    end
  end

  relationships do
    belongs_to :poster, PhpBB.Users do
      destination_attribute :user_id
      source_attribute :poster_id
      attribute_type :integer
    end

    belongs_to :topic, PhpBB.Topics do
      destination_attribute :topic_id
      source_attribute :topic_id
      attribute_type :integer
    end

    belongs_to :forum, PhpBB.Forums do
      destination_attribute :forum_id
      source_attribute :forum_id
      attribute_type :integer
    end

    has_one :post_text, PhpBB.PostsText do
      destination_attribute :post_id
      source_attribute :post_id
    end
  end
end

defimpl SEO.OpenGraph.Build, for: PhpBB.Posts do
  use SambaWeb, :verified_routes

  def build(post, conn) do
    SEO.OpenGraph.build(
      detail:
        SEO.OpenGraph.post().build(
          published_time: post.published_at,
          author: post.author,
          section: "Automotive"
        ),
      image: image(post, conn),
      title: post.title,
      description: post.description
    )
  end

  defp image(post, conn) do
    file = "/images/post/#{post.id}.png"

    exists? =
      [:code.priv_dir(:my_app), "static", file]
      |> Path.join()
      |> File.exists?()

    if exists? do
      SEO.OpenGraph.Image.build(
        url: static_url(conn, file),
        alt: post.title
      )
    end
  end
end

defimpl SEO.Site.Build, for: PhpBB.Posts do
  use SambaWeb, :verified_routes

  def build(post, conn) do
    SEO.Site.build(
      url: url(conn, ~p"/posts/#{post}"),
      title: post.title,
      description: post.description
    )
  end
end

defimpl SEO.Twitter.Build, for: PhpBB.Posts do
  def build(post, _conn) do
    SEO.Twitter.build(description: post.description, title: post.title)
  end
end
