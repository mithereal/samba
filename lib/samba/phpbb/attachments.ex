defmodule PhpBB.Attachment do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub]

  postgres do
    table "phpbb_attachments"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  attributes do
    attribute :attach_id, :integer do
      public? true
      primary_key? true
      allow_nil? false

      description "Foreign or primary key reference linking to the corresponding attachment description record."
    end

    attribute :post_id, :integer do
      public? true
      allow_nil? false

      description "The ID of the public forum post where the attachment is attached (0 if attached to a private message)."
    end

    attribute :privmsgs_id, :integer do
      public? true
      default 0
      allow_nil? false

      description "The ID of the private message where the attachment is attached (0 if attached to a public post)."
    end

    attribute :user_id_1, :integer do
      public? true
      allow_nil? false

      description "The primary user ID context reference, typically representing the sender or uploader."
    end

    attribute :user_id_2, :integer do
      public? true
      default 0
      allow_nil? false

      description "The secondary user ID context reference, typically representing the private message recipient or moderation target."
    end
  end
end
