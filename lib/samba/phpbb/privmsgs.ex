defmodule PhpBB.Privmsgs do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_privmsgs"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      accept [
        :privmsgs_id,
        :privmsgs_from_userid,
        :privmsgs_to_userid,
        :privmsgs_type,
        :privmsgs_subject,
        :privmsgs_date,
        :privmsgs_ip,
        :privmsgs_enable_bbcode,
        :privmsgs_enable_html,
        :privmsgs_enable_smilies,
        :privmsgs_attach_sig
      ]
    end
  end

  attributes do
    attribute :privmsgs_id, :integer do
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :privmsgs_from_userid, :integer do
      allow_nil? false
    end

    attribute :privmsgs_to_userid, :integer do
      allow_nil? false
    end

    relationships do
      belongs_to :from, PhpBB.Users do
        source_attribute :privmsgs_from_userid
        destination_attribute :user_id
        attribute_type :integer
      end

      belongs_to :to, PhpBB.Users do
        source_attribute :privmsgs_to_userid
        destination_attribute :user_id
        attribute_type :integer
      end
    end

    attribute :privmsgs_type, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true
    end

    attribute :privmsgs_subject, :string do
      allow_nil? false
      default "0"
      public? true
    end

    attribute :privmsgs_date, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :privmsgs_ip, :string do
      allow_nil? false
      public? true
    end

    attribute :privmsgs_enable_bbcode, :integer do
      allow_nil? false
      constraints min: -32768, max: 32767
      default 1
      public? true
    end

    attribute :privmsgs_enable_html, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true
    end

    attribute :privmsgs_enable_smilies, :integer do
      constraints min: -32768, max: 32767
      default 1
      allow_nil? false
      public? true
    end

    attribute :privmsgs_attach_sig, :integer do
      constraints min: -32768, max: 32767
      default 1
      allow_nil? false
      public? true
    end
  end

  identities do
    identity :unique_name, [:privmsgs_from_userid]
    identity :unique_name, [:privmsgs_to_userid]
  end
end
