defmodule PhpBB.Seed do
  @moduledoc """
  A modular seed script to populate the phpBB domain models with realistic mock data using Faker,
  organizing each entity type into its own dedicated helper function orchestrated via `run/0`.
  """

  def run do
    IO.puts("Starting phpBB database seeding...")

    ranks = seed_ranks()
    users = seed_users(ranks)
    groups = seed_groups(users)
    seed_user_groups(users, groups)
    categories = seed_categories()
    forums = seed_forums(categories)
    seed_ban_list(users)
    seed_auth_access(forums, groups)
    seed_words()
    seed_smiles()
    seed_faq_items()
    seed_topics_and_posts(forums, users)

    IO.puts("Database seeding completed successfully!")
  end

  def seed_ranks do
    IO.puts("Seeding Ranks...")
    for _ <- 1..5 do
      {:ok, rank} =
        PhpBB.Ranks
        |> Ash.Changeset.for_create(:create, %{
          rank_title: Faker.Lorem.word() |> String.capitalize(),
          rank_min: Enum.random(0..100),
          rank_special: Enum.random(0..1),
          rank_image: "images/ranks/" <> Faker.Internet.slug()
        })
        |> Ash.create(domain: PhpBB.Domain)

      rank
    end
  end

  def seed_users(ranks) do
    IO.puts("Seeding Users...")
    for _ <- 1..25 do
      {:ok, user} =
        PhpBB.Users
        |> Ash.Changeset.for_create(:create, %{
          username: Faker.Internet.user_name(),
          user_email: Faker.Internet.email(),
          user_password: "$2y$10$" <> Base.encode16(:crypto.strong_rand_bytes(16)),
          user_regdate: System.system_time(:second),
          user_lastvisit: System.system_time(:second),
          user_posts: Enum.random(0..150),
          user_rank: Enum.random(ranks).rank_id,
          user_active: 1,
          user_level: 0,
          user_timezone: Decimal.new("0.0"),
          user_dateformat: "d M Y H:i",
          user_allow_pm: 1,
          user_allowavatar: 1,
          user_allow_viewonline: 1,
          user_from: Faker.Address.city(),
          user_occ: Faker.Company.bullshit(),
          user_interests: Faker.Lorem.word() <> ", " <> Faker.Lorem.word()
        })
        |> Ash.create(domain: PhpBB.Domain)

      user
    end
  end

  def seed_groups(users) do
    IO.puts("Seeding Groups...")
    moderator_user = Enum.random(users)
    for _ <- 1..3 do
      {:ok, group} =
        PhpBB.Groups
        |> Ash.Changeset.for_create(:create, %{
          group_name: Faker.Team.name(),
          group_description: Faker.Lorem.sentence(5..10),
          group_moderator: moderator_user.user_id,
          group_single_user: 0,
          group_type: 1
        })
        |> Ash.create(domain: PhpBB.Domain)

      group
    end
  end

  def seed_user_groups(users, groups) do
    IO.puts("Seeding User Group memberships...")
    for user <- users, group <- Enum.take(groups, 1) do
      PhpBB.UserGroup
      |> Ash.Changeset.for_create(:create, %{
        group_id: group.group_id,
        user_id: user.user_id,
        user_pending: 0
      })
      |> Ash.create(domain: PhpBB.Domain)
    end
  end

  def seed_categories do
    IO.puts("Seeding Categories...")
    for i <- 1..3 do
      {:ok, category} =
        PhpBB.Categories
        |> Ash.Changeset.for_create(:create, %{
          cat_title: Faker.Lorem.word() |> String.capitalize(),
          cat_order: i
        })
        |> Ash.create(domain: PhpBB.Domain)

      category
    end
  end

  def seed_forums(categories) do
    IO.puts("Seeding Forums...")
    for category <- categories, j <- 1..3 do
      {:ok, forum} =
        PhpBB.Forums
        |> Ash.Changeset.for_create(:create, %{
          cat_id: category.cat_id,
          forum_name: Faker.Lorem.sentence(2..4) |> String.trim_trailing("."),
          forum_desc: Faker.Lorem.sentence(6..12),
          forum_order: j,
          forum_status: 0,
          forum_last_post_id: 0,
          prune_enable: 0
        })
        |> Ash.create(domain: PhpBB.Domain)

      forum
    end
  end

  def seed_ban_list(users) do
    IO.puts("Seeding Ban List...")
    banned_user = Enum.random(users)
    ban_entries = [
      %{ban_userid: banned_user.user_id, ban_ip: nil, ban_email: nil},
      %{ban_userid: 0, ban_ip: Faker.Internet.ip_v4_address(), ban_email: nil},
      %{ban_userid: 0, ban_ip: nil, ban_email: "spammer@" <> Faker.Internet.domain_name()}
    ]

    for ban_attrs <- ban_entries do
      PhpBB.BanList
      |> Ash.Changeset.for_create(:create, ban_attrs)
      |> Ash.create(domain: PhpBB.Domain)
    end
  end

  def seed_auth_access(forums, groups) do
    IO.puts("Seeding Auth Access Controls...")
    for forum <- forums, group <- groups do
      PhpBB.AuthAccess
      |> Ash.Changeset.for_create(:create, %{
        group_id: group.group_id,
        forum_id: forum.forum_id,
        auth_view: 0,
        auth_read: 0,
        auth_post: 0,
        auth_reply: 0,
        auth_edit: 0,
        auth_delete: 0,
        auth_sticky: 1,
        auth_announce: 1,
        auth_vote: 0,
        auth_pollcreate: 0,
        auth_attachments: 0,
        auth_mod: 0
      })
      |> Ash.create(domain: PhpBB.Domain)
    end
  end

  def seed_words do
    IO.puts("Seeding Word Censors...")
    words_data = [
      {"damn", ":censored:"},
      {"hell", ":censored:"},
      {"idiot", "[blocked]"},
      {"stupid", "[blocked]"}
    ]

    for {word, replacement} <- words_data do
      PhpBB.Words
      |> Ash.Changeset.for_create(:create, %{
        word: word,
        replacement: replacement
      })
      |> Ash.create(domain: PhpBB.Domain)
    end
  end

  def seed_smiles do
    IO.puts("Seeding Smiles...")
    smiles_data = [
      {":)", "icon_smile.gif", "Smile"},
      {":-)", "icon_smile.gif", "Smile"},
      {":(", "icon_sad.gif", "Sad"},
      {":-(", "icon_sad.gif", "Sad"},
      {":D", "icon_biggrin.gif", "Very Happy"},
      {":-D", "icon_biggrin.gif", "Very Happy"},
      {";)", "icon_wink.gif", "Wink"},
      {";-)", "icon_wink.gif", "Wink"},
      {":p", "icon_razz.gif", "Razz"},
      {":-p", "icon_razz.gif", "Razz"},
      {":o", "icon_surprised.gif", "Surprised"},
      {":shock:", "icon_eek.gif", "Shocked"}
    ]

    for {code, url, emoticon} <- smiles_data do
      PhpBB.Smiles
      |> Ash.Changeset.for_create(:create, %{
        code: code,
        smile_url: "images/smiles/" <> url,
        emoticon: emoticon
      })
      |> Ash.create(domain: PhpBB.Domain)
    end
  end

  def seed_faq_items do
    IO.puts("Seeding FAQ Items...")
    sections = ["General", "BBCode", "Profile", "Posting"]
    for {section, _s_idx} <- Enum.with_index(sections, 1) do
      for p_idx <- 1..3 do
        PhpBB.FaqItem
        |> Ash.Changeset.for_create(:import_item, %{
          variable: "faq",
          section: section,
          question: Faker.Lorem.paragraphs(),
          answer: Faker.Lorem.paragraphs(),
          position: p_idx
        })
        |> Ash.create(domain: PhpBB.Domain)
      end
    end
  end

  def seed_topics_and_posts(forums, users) do
    IO.puts("Seeding Topics, Posts, Content, Polls, Vote Results, and Voters...")
    for forum <- forums, k <- 1..4 do
      poster = Enum.random(users)
      topic_title = Faker.Lorem.sentence(3..6) |> String.trim_trailing(".")
      topic_time = System.system_time(:second) - Enum.random(1_000..500_000)
      is_sticky = if k == 1, do: 1, else: 0
      has_vote = (k == 2)

      {:ok, topic} =
        PhpBB.Topics
        |> Ash.Changeset.for_create(:create, %{
          forum_id: forum.forum_id,
          topic_poster: poster.user_id,
          topic_title: topic_title,
          topic_time: topic_time,
          topic_views: Enum.random(15..400),
          topic_replies: 0,
          topic_status: 0,
          topic_vote: if(has_vote, do: 1, else: 0),
          topic_type: is_sticky
        })
        |> Ash.create(domain: PhpBB.Domain)

      if has_vote do
        {:ok, vote_desc} =
          PhpBB.VoteDesc
          |> Ash.Changeset.for_create(:create, %{
            topic_id: topic.topic_id,
            vote_text: Faker.Lorem.question(),
            vote_start: topic_time,
            vote_length: 86400 * 7
          })
          |> Ash.create(domain: PhpBB.Domain)

        for option_id <- 1..3 do
          PhpBB.VoteResults
          |> Ash.Changeset.for_create(:create, %{
            vote_id: vote_desc.vote_id,
            vote_option_id: option_id,
            vote_option_text: Faker.Lorem.word() |> String.capitalize(),
            vote_result: Enum.random(0..15)
          })
          |> Ash.create(domain: PhpBB.Domain)
        end

        voter_subset = Enum.take_random(users, Enum.random(1..5))
        for voter <- voter_subset do
          PhpBB.VoteVoters
          |> Ash.Changeset.for_create(:create, %{
            vote_id: vote_desc.vote_id,
            vote_user_id: voter.user_id,
            vote_user_ip: Faker.Internet.ip_v4_address()
          })
          |> Ash.create(domain: PhpBB.Domain)
        end
      end

      {:ok, initial_post} =
        PhpBB.Posts
        |> Ash.Changeset.for_create(:create, %{
          topic_id: topic.topic_id,
          forum_id: forum.forum_id,
          poster_id: poster.user_id,
          post_time: topic_time,
          enable_bbcode: 1,
          enable_smilies: 1,
          enable_sig: 1
        })
        |> Ash.create(domain: PhpBB.Domain)

      PhpBB.PostsText
      |> Ash.Changeset.for_create(:create, %{
        post_id: initial_post.post_id,
        bbcode_uid: "abc123xyz",
        post_subject: topic_title,
        post_text: Faker.Lorem.paragraph(3..6)
      })
      |> Ash.create(domain: PhpBB.Domain)

      topic =
        topic
        |> Ash.Changeset.for_update(:update, %{
          first_post_id: initial_post.post_id,
          last_post_id: initial_post.post_id
        })
        |> Ash.update!(domain: PhpBB.Domain)

      forum
      |> Ash.Changeset.for_update(:update, %{forum_last_post_id: initial_post.post_id})
      |> Ash.update!(domain: PhpBB.Domain)

      reply_count = Enum.random(1..3)
      for r <- 1..reply_count do
        replier = Enum.random(users)
        reply_time = topic_time + (r * 3600)

        {:ok, reply_post} =
          PhpBB.Posts
          |> Ash.Changeset.for_create(:create, %{
            topic_id: topic.topic_id,
            forum_id: forum.forum_id,
            poster_id: replier.user_id,
            post_time: reply_time,
            enable_bbcode: 1,
            enable_smilies: 1
          })
          |> Ash.create(domain: PhpBB.Domain)

        PhpBB.PostsText
        |> Ash.Changeset.for_create(:create, %{
          post_id: reply_post.post_id,
          bbcode_uid: "abc123xyz",
          post_subject: "Re: " <> topic_title,
          post_text: Faker.Lorem.paragraph(1..3)
        })
        |> Ash.create(domain: PhpBB.Domain)

        topic =
          topic
          |> Ash.Changeset.for_update(:update, %{
            topic_replies: topic.topic_replies + 1,
            last_post_id: reply_post.post_id
          })
          |> Ash.update!(domain: PhpBB.Domain)

        forum
        |> Ash.Changeset.for_update(:update, %{forum_last_post_id: reply_post.post_id})
        |> Ash.update!(domain: PhpBB.Domain)
      end
    end
  end
end