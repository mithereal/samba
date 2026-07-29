defmodule PhpBB.Users do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_users"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :user_id,
        :user_active,
        :username,
        :user_regdate,
        :user_password,
        :user_session_time,
        :user_session_page,
        :user_lastvisit,
        :user_email,
        :user_icq,
        :user_website,
        :user_occ,
        :user_from,
        :user_interests,
        :user_sig,
        :user_sig_bbcode_uid,
        :user_style,
        :user_aim,
        :user_yim,
        :user_msnm,
        :user_posts,
        :user_new_privmsg,
        :user_unread_privmsg,
        :user_last_privmsg,
        :user_login_tries,
        :user_last_login_try,
        :user_emailtime,
        :user_viewemail,
        :user_attachsig,
        :user_allowhtml,
        :user_allowbbcode,
        :user_allowsmile,
        :user_allow_pm,
        :user_allowavatar,
        :user_allow_viewonline,
        :user_avatar,
        :user_avatar_type,
        :user_level,
        :user_lang,
        :user_timezone,
        :user_rank,
        :user_dateformat,
        :user_notify_pm,
        :user_popup_pm,
        :user_notify,
        :user_actkey,
        :user_newpasswd
      ]
    end

    read :fetch_profile do
      argument :user_id, :integer do
        allow_nil? false
      end

      filter expr(user_id == ^arg(:user_id))
    end
  end

  def fetch_user_profile(user_id) when is_binary(user_id) do
    case Integer.parse(user_id) do
      {id, _} -> fetch_user_profile(id)
      :error -> nil
    end
  end

  def fetch_user_profile(user_id) do
    user =
      __MODULE__
      |> Ash.Query.for_read(:fetch_profile, %{user_id: user_id})
      |> Ash.read_one!(domain: PhpBB.Domain)

    case user do
      nil ->
        nil

      user ->
        joined_date =
          if user.user_regdate && user.user_regdate > 0 do
            user.user_regdate
            |> DateTime.from_unix!()
            |> Calendar.strftime("%B %d, %Y")
          else
            "Unknown"
          end

        %{
          username: user.username,
          user_id: user.user_id,
          online?: false,
          joined_date: joined_date,
          last_visited: "Today",
          total_posts: user.user_posts || 0,
          posts_percentage: "0.00",
          posts_per_day: "0.00",
          total_photos: 0,
          favorite_photos: 0,
          classified_ads_count: 0,
          location: user.user_from,
          website: user.user_website,
          occupation: user.user_occ,
          interests: user.user_interests,
          email: user.user_email,
          messenger_msn: user.user_msnm,
          messenger_yahoo: user.user_yim,
          social_facebook: nil,
          social_twitter: nil,
          social_instagram: nil,
          social_youtube: nil,
          aim_address: user.user_aim,
          icq_number: user.user_icq,
          user_avatar: user.user_avatar
        }
    end
  end

  attributes do
    attribute :user_id, :integer do
      public? true
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :user_rank, :integer do
      allow_nil? false
    end

    attribute :user_active, :integer do
      constraints min: -32768, max: 32767
      public? true
    end

    attribute :username, :string do
      allow_nil? false
      public? true
    end

    attribute :user_regdate, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :user_password, :string do
      allow_nil? false
      default "0"
      public? true
    end

    attribute :user_session_time, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :user_session_page, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true
    end

    attribute :user_lastvisit, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :user_email, :string do
      allow_nil? true
      public? true
    end

    attribute :user_icq, :string do
      allow_nil? true
      public? true
    end

    attribute :user_website, :string do
      allow_nil? true
      public? true
    end

    attribute :user_occ, :string do
      allow_nil? true
      public? true
    end

    attribute :user_from, :string do
      allow_nil? true
      public? true
    end

    attribute :user_interests, :string do
      allow_nil? true
      public? true
    end

    attribute :user_sig, :string do
      allow_nil? true
      public? true
    end

    attribute :user_sig_bbcode_uid, :string do
      allow_nil? true
      public? true
    end

    attribute :user_style, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_aim, :string do
      allow_nil? true
      public? true
    end

    attribute :user_yim, :string do
      allow_nil? true
      public? true
    end

    attribute :user_msnm, :string do
      allow_nil? true
      public? true
    end

    attribute :user_posts, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :user_new_privmsg, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true
    end

    attribute :user_unread_privmsg, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true
    end

    attribute :user_last_privmsg, :integer do
      default 0
      allow_nil? false
      public? true
    end

    attribute :user_login_tries, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true
    end

    attribute :user_last_login_try, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :user_emailtime, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_viewemail, :integer do
      constraints min: -32768, max: 32767
      public? true
    end

    attribute :user_attachsig, :integer do
      constraints min: -32768, max: 32767
      allow_nil? true
      public? true
    end

    attribute :user_allowhtml, :integer do
      constraints min: -32768, max: 32767
      default 1
      public? true
    end

    attribute :user_allowbbcode, :integer do
      constraints min: -32768, max: 32767
      default 1
      public? true
    end

    attribute :user_allowsmile, :integer do
      constraints min: -32768, max: 32767
      default 1
      public? true
    end

    attribute :user_allow_pm, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true
    end

    attribute :user_allowavatar, :integer do
      constraints min: -32768, max: 32767
      default 1
      allow_nil? false
      public? true
    end

    attribute :user_allow_viewonline, :integer do
      constraints min: -32768, max: 32767
      default 1
      allow_nil? false
      public? true
    end

    relationships do
      belongs_to :rank, PhpBB.Ranks do
        destination_attribute :rank_id
        source_attribute :user_rank
        attribute_type :integer
      end
    end

    attribute :user_avatar, :string do
      allow_nil? true
      public? true
    end

    attribute :user_avatar_type, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true
    end

    attribute :user_level, :integer do
      allow_nil? true
      default 0
      public? true
    end

    attribute :user_lang, :string do
      allow_nil? true
      public? true
    end

    attribute :user_timezone, :decimal do
      default 0.0
      allow_nil? false
      public? true
    end

    attribute :user_dateformat, :string do
      default "d M Y H:i"
      allow_nil? false
      public? true
    end

    attribute :user_notify_pm, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true
    end

    attribute :user_popup_pm, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true
    end

    attribute :user_notify, :integer do
      constraints min: -32768, max: 32767
      allow_nil? true
      public? true
    end

    attribute :user_actkey, :string do
      allow_nil? true
      public? true
    end

    attribute :user_newpasswd, :string do
      allow_nil? true
      public? true
    end
  end
end
