defmodule PhpBB.Privmsgs do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_privmsgs"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:privmsgs_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:privmsgs_id)

    attribute :privmsgs_type, :integer do
      allow_nil? true
      public? true
    end

    attribute :privmsgs_subject, :string do
      allow_nil? true
      public? true
    end

    attribute :privmsgs_from_userid, :integer do
      allow_nil? true
      public? true
    end

    attribute :privmsgs_to_userid, :integer do
      allow_nil? true
      public? true
    end

    attribute :privmsgs_date, :integer do
      allow_nil? true
      public? true
    end

    attribute :privmsgs_ip, :string do
      allow_nil? true
      public? true
    end

    attribute :privmsgs_enable_bbcode, :integer do
      allow_nil? true
      public? true
    end

    attribute :privmsgs_enable_html, :integer do
      allow_nil? true
      public? true
    end

    attribute :privmsgs_enable_smilies, :integer do
      allow_nil? true
      public? true
    end

    attribute :privmsgs_attach_sig, :integer do
      allow_nil? true
      public? true
    end
  end
end
