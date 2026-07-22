defmodule PhpBB.Posts do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
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
        :post_id,
        :topic_id,
        :forum_id,
        :poster_id,
        :post_username,
        :post_time,
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
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :topic_id, :integer do
      allow_nil? false
      default 0
    end

    attribute :forum_id, :integer do
      allow_nil? false
      default 0
    end

    attribute :poster_id, :integer do
      allow_nil? false
      default 0
    end

    attribute :post_username, :integer do
      allow_nil? false
      default 0
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
    end

    attribute :post_time, :integer do
      allow_nil? false
      public? true
      default 0
    end

    attribute :poster_ip, :integer do
      allow_nil? false
      public? true
      default 0
    end

    attribute :enable_bbcode, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 1
      public? true
    end

    attribute :enable_html, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 0
      public? true
    end

    attribute :enable_smilies, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 1
      public? true
    end

    attribute :enable_sig, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 1
      public? true
    end

    attribute :post_edit_time, :integer

    attribute :post_edit_count, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 0
      public? true
    end
  end

  identities do
    identity :unique_name, [:forum_id]
    identity :unique_name, [:post_time]
    identity :unique_name, [:poster_id]
    identity :unique_name, [:topic_id]
  end

  #  reading_time
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
    # Because of `Phoenix.Param`, structs will assume the key of `:id` when
    # interpolating the struct into the verified route.
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

defimpl SEO.Unfurl.Build, for: PhpBB.Posts do
  def build(post, _conn) do
    SEO.Unfurl.build(
      label1: "Reading Time",
      data1: post.reading_time,
      label2: "Published",
      data2: DateTime.to_iso8601(post.published_at)
    )
  end
end

defimpl SEO.JSONLD.Build, for: PhpBB.Posts do
  use SambaWeb, :verified_routes

  def build(post, conn) do
    # Because of `Phoenix.Param`, structs will assume the key of `:id` when
    # interpolating the struct into the verified route. Emit multiple JSON-LD
    # entities by returning a list — breadcrumbs sit alongside the post.
    [
      SEO.JSONLD.post().build(%{
        headline: post.title,
        description: post.description,
        date_published: post.published_at,
        author: SEO.JSONLD.Person.build(%{name: post.author}),
        main_entity_of_page: url(conn, ~p"/posts/#{post}")
      }),
      SEO.JSONLD.Breadcrumbs.build([
        %{name: "posts", item: url(conn, ~p"/posts")},
        %{name: post.title, item: url(conn, ~p"/posts/#{post}")}
      ])
    ]
  end
end
