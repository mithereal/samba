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
      public? true
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :privmsgs_from_userid, :integer do
      public? true
      allow_nil? false
    end

    attribute :privmsgs_to_userid, :integer do
      public? true
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

      description "0 (PRIVMSGS_READ_MAIL / PRIVMSGS_NEW_MAIL):Represents an incoming message that has been delivered to the recipient's inbox.Initially flagged as new/unread when it arrives, it often transitions programmatically to a standard read state once the recipient opens and views the message.1 (PRIVMSGS_READ_MAIL):Standard flag for a message that resides in the user's Inbox and has already been opened or acknowledged.2 (PRIVMSGS_SEND_MAIL):Used transiently or during the queueing phase when a message is actively being dispatched from the sender.3 (PRIVMSGS_SAVED_OUT_MAIL):Represents a message stored in the sender's Outbox. These are messages that have been successfully sent but have not yet been read or picked up by the recipient.4 (PRIVMSGS_SAVED_IN_MAIL):Represents a message that the recipient has explicitly moved to their Saved / Archive folder to prevent it from being purged by inbox capacity limits."
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
    identity :privmsgs_from_userid_phpbb_privmsgs_index, [:privmsgs_from_userid]
    identity :privmsgs_to_userid_phpbb_privmsgs_index, [:privmsgs_to_userid]
  end
end
