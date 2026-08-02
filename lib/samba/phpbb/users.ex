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

    attribute :user_active, :boolean do
      public? true
      default true
      allow_nil? false
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

      description "Integer Mapping: Rather than storing a bulky URL string, user_session_page typically stores an integer corresponding to a specific script file or module ID mapped inside the forum logic (for example, representing index.php, viewforum.php, viewtopic.php, or the User Control Panel)."
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

      description "Positive Integers (1, 2, 3, etc.): Represents the exact count of unread incoming private messages that have not yet been opened or read by the user."
    end

    attribute :user_unread_privmsg, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true

      description "Real-Time Badge Updates: Instead of querying the entire phpbb_privmsgs table every time a page loads to count messages flagged as unread (privs_type or read status), phpBB maintains this cached integer directly on the user record. UI Notification: When a new private message arrives, this integer increments by 1. The forum engine reads this value on every page load to instantly decide whether to display the flashing New Messages banner or notification box in the header navigation. Once the user opens and reads the message, the system decrements this counter."
    end

    attribute :user_last_privmsg, :integer do
      default 0
      allow_nil? false
      public? true

      description "Tracking Activity: The board updates this value whenever a new private message hits the user's inbox or when they dispatch an outbound message. Session & Notification Triggers: While columns like user_unread_privmsg handle the unread badge count, user_last_privmsg helps the engine track private message history timelines and can be used to coordinate popup notification alerts when a fresh message arrives during an active session."
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

    attribute :user_viewemail, :boolean do
      public? true
      default true
      allow_nil? false

      description "0 (Hidden / Private): The user's email address is kept private. Other members cannot see the email address in user profiles, and they must use phpBB's internal web-based email form (profile.php?mode=email) to contact the user without revealing the underlying address. 1 (Visible / Public): The user's email address is publicly exposed in their profile view, allowing anyone browsing the forum to see their raw email address."
    end

    attribute :user_attachsig, :boolean do
      public? true
      default true
      allow_nil? false
    end

    attribute :user_allowhtml, :boolean do
      public? true
      default true
      allow_nil? false
    end

    attribute :user_allowbbcode, :boolean do
      public? true
      default true
      allow_nil? false
    end

    attribute :user_allowsmile, :boolean do
      public? true
      default true
      allow_nil? false
    end

    attribute :user_allow_pm, :boolean do
      public? true
      default true
      allow_nil? false
    end

    attribute :user_allowavatar, :boolean do
      public? true
      default true
      allow_nil? false
    end

    attribute :user_allow_viewonline, :boolean do
      public? true
      default true
      allow_nil? false
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

      description "If Avatar Type is Remote (2): It stores the full external URL pointing to an image hosted on a third-party server (e.g., [https://example.com/my-avatar.png](https://example.com/my-avatar.png)). If Avatar Type is Upload (1) or Gallery (3): It stores the specific filename or relative path identifier assigned by the forum's upload handler (e.g., 12345678904f2b1a.jpg or gallery/cat_01.gif). If Avatar Type is None (0): The field remains empty (NULL or an empty string)."
    end

    attribute :user_avatar_type, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true

      description "0 (None / No Avatar): The user has no avatar selected or displayed. 1 (Upload / Gallery): The avatar image file is stored directly on the server's local filesystem (typically inside an images/avatars/uploaded/ or gallery directory). The database stores the filename generated during upload. 2 (Remote / Linked URL): The avatar is hotlinked from an external website. The corresponding avatar text column stores a full external URL pointing to an image hosted elsewhere. 3 (Gallery Preset): The avatar is selected from a predefined pack of standard images bundled locally with the forum installation."
    end

    attribute :user_level, :integer do
      allow_nil? true
      default 0
      public? true

      description "0 (Standard User / Registered User): The default tier for normal members. These users have standard posting, reading, and private messaging rights based on group permissions, but hold no administrative or moderator privileges. 1 (Administrator): Grants full administrative access, allowing the user to manage board configurations, user accounts, ranks, categories, database backups, and global permissions via the administration control panel (ACP). 2 (Moderator): Grants global moderation privileges, allowing the user to edit, delete, move, lock, and split posts and topics across all forums on the board without needing individual forum-by-forum moderator assignments."
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

    attribute :user_notify_pm, :boolean do
      public? true
      default true
      allow_nil? false

      description "0 (Disabled): The user does not want email alerts. They will only see the private message notification badge or popup when actively browsing the forum. 1 (Enabled): The user wants to be notified via email whenever someone sends them a private message"
    end

    attribute :user_popup_pm, :boolean do
      public? true
      default true
      allow_nil? false
    end

    attribute :user_notify, :boolean do
      public? true
      default true
      allow_nil? false
      description "The system automatically send an email to the user's registered address"
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
