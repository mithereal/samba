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
    defaults [:read, :destroy]

    create :create do
      primary? true

      accept [
        :topic_id,
        :forum_id,
        :poster_id,
        :post_username,
        :post_time,
        :poster_ip,
        :enable_bbcode,
        :enable_html,
        :enable_smilies,
        :enable_sig
      ]

      argument :post_subject, :string, allow_nil?: false
      argument :post_text, :string, allow_nil?: false
      argument :bbcode_uid, :string,  default: ""

      change fn changeset, _context ->
        subject = Ash.Changeset.get_argument(changeset, :post_subject)
        text = Ash.Changeset.get_argument(changeset, :post_text)
        bbcode_uid_val =
          case Ash.Changeset.get_argument(changeset, :bbcode_uid) do
            val when val in [nil, ""] -> "0"
            val -> val
          end
        Ash.Changeset.after_action(changeset, fn changeset, post ->
          text_params = %{
            post_id: post.post_id,
            post_subject: subject,
            post_text: text,
            bbcode_uid: bbcode_uid_val
          }

          result =
            Ash.DataLayer.transaction(
              changeset.resource,
              fn ->
                case PhpBB.PostsText
                     |> Ash.Changeset.for_create(:create, text_params)
                     |> Ash.create() do
                  {:ok, posts_text} ->
                    {:ok, {post, posts_text}}

                  {:error, error} ->
                    Ash.DataLayer.rollback(changeset.resource, error)
                end
              end,
              repo: Samba.Repo
            )

          case result do
            {:ok, {post, _text}} ->
              {:ok, post}

            {:error, error} ->
              require Logger

              Logger.error(
                "Failed atomic creation of post and PostsText: #{inspect(error, pretty: true)}"
              )

              {:error, error}
          end
        end)
      end
    end

#    update :update do
#      primary? true
#
#      accept [
#        :topic_id,
#        :forum_id,
#        :poster_id,
#        :post_username,
#        :post_time,
#        :poster_ip,
#        :enable_bbcode,
#        :enable_html,
#        :enable_smilies,
#        :enable_sig,
#        :post_edit_time,
#        :post_edit_count
#      ]
#
#      argument :post_subject, :string, allow_nil?: true
#      argument :post_text, :string, allow_nil?: true
#
#      change fn changeset, _context ->
#        subject = Ash.Changeset.get_argument(changeset, :post_subject)
#        text = Ash.Changeset.get_argument(changeset, :post_text)
#        bbcode_uid_val = Ash.Changeset.get_attribute(changeset, :bbcode_uid) || ""
#
#        Ash.Changeset.after_action(changeset, fn _changeset, post ->
#          if subject || text do
#            posts_text_record =
#              PhpBB.PostsText
#              |> Ash.get(post.post_id)
#
#            text_params =
#              %{}
#              |> then(fn map ->
#                if subject, do: Map.put(map, :post_subject, subject), else: map
#              end)
#              |> then(fn map -> if text, do: Map.put(map, :post_text, text), else: map end)
#              |> Map.put(:bbcode_uid, bbcode_uid_val)
#
#            case posts_text_record do
#              nil ->
#                full_params =
#                  Map.merge(
#                    %{
#                      post_id: post.post_id,
#                      bbcode_uid: bbcode_uid_val
#                    },
#                    text_params
#                  )
#
#                case PhpBB.PostsText
#                     |> Ash.Changeset.for_create(:create, full_params)
#                     |> Ash.create() do
#                  {:ok, _} ->
#                    {:ok, post}
#
#                  {:error, error} ->
#                    require Logger
#
#                    Logger.error(
#                      "Failed to create missing PostsText during update: #{inspect(error, pretty: true)}"
#                    )
#
#                    {:error, error}
#                end
#
#              existing_text ->
#                case PhpBB.PostsText
#                     |> Ash.Changeset.for_update(:update, text_params, record: existing_text)
#                     |> Ash.update() do
#                  {:ok, _} ->
#                    {:ok, post}
#
#                  {:error, error} ->
#                    require Logger
#                    Logger.error("Failed to update PostsText: #{inspect(error, pretty: true)}")
#                    {:error, error}
#                end
#            end
#          else
#            {:ok, post}
#          end
#        end)
#      end
#    end
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

    attribute :post_username, :string do
      public? true
      allow_nil? true
    end

    attribute :post_time, :integer do
      allow_nil? false
      public? true
      default 0
    end

    attribute :poster_ip, :string do
      allow_nil? false
      public? true
      default "00000000"
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

    attribute :post_edit_time, :integer do
      public? true
    end

    attribute :post_edit_count, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 0
      public? true
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