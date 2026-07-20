defmodule PhpBB.Users do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_users"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:user_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:user_id)

    attribute :user_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_active, :integer do
      allow_nil? true
      public? true
    end

    attribute :username, :string do
      allow_nil? true
      public? true
    end

    attribute :user_regdate, :string do
      allow_nil? true
      public? true
    end

    attribute :user_password, :string do
      allow_nil? true
      public? true
    end

    attribute :user_session_time, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_session_page, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_lastvisit, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_email, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_icq, :string do
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
      allow_nil? true
      public? true
    end

    attribute :user_new_privmsg, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_unread_privmsg, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_last_privmsg, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_login_tries, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_last_login_try, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_emailtime, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_viewemail, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_attachsig, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_allowhtml, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_allowbbcode, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_allowsmile, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_allow_pm, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_allowavatar, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_allow_viewonline, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_rank, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_avatar, :string do
      allow_nil? true
      public? true
    end

    attribute :user_avatar_type, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_level, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_lang, :string do
      allow_nil? true
      public? true
    end

    attribute :user_timezone, :decimal do
      allow_nil? true
      public? true
    end

    attribute :user_dateformat, :string do
      allow_nil? true
      public? true
    end

    attribute :user_notify_pm, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_popup_pm, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_notify, :integer do
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
