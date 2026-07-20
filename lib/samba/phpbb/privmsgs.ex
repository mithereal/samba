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
    integer_primary_key(:privmsgs_id)

    relationships do
      belongs_to :from, PhpBB.Users do
        destination_attribute :privmsgs_from_userid
      end

      belongs_to :to, PhpBB.Users do
        destination_attribute :privmsgs_to_userid
      end
    end

    attribute :privmsgs_type, :integer do
      allow_nil? true
      public? true
    end

    attribute :privmsgs_subject, :string do
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
