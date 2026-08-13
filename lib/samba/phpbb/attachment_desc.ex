defmodule PhpBB.AttachmentDesc do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub]

  postgres do
    table "phpbb_attachments_desc"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  attributes do
    attribute :attach_id, :integer do
      public? true
      generated? true
      primary_key? true
      allow_nil? false
      description "Unique primary key identifier for the attachment description record."
    end

    attribute :physical_filename, :string do
      public? true
      allow_nil? false

      description "The obfuscated or hashed filename stored on the server's filesystem upload directory."
    end

    attribute :real_filename, :string do
      public? true
      allow_nil? false
      description "The original, human-readable filename provided by the user when uploading."
    end

    attribute :download_count, :integer do
      public? true
      default 0
      allow_nil? false
      description "Total number of times this specific file has been downloaded."
    end

    attribute :comment, :string do
      public? true
      allow_nil? true
      description "Optional user-supplied description or caption associated with the attachment."
    end

    attribute :extension, :string do
      public? true
      allow_nil? true
      description "File extension type (e.g., 'jpg', 'zip', 'pdf')."
    end

    attribute :mimetype, :string do
      public? true
      allow_nil? true
      description "Standard internet media type indicating the file format (e.g., 'image/jpeg')."
    end

    attribute :filesize, :integer do
      public? true
      allow_nil? false
      description "Total size of the file measured in bytes."
    end

    attribute :filetime, :integer do
      public? true
      allow_nil? false
      description "Unix timestamp representing when the file was originally uploaded."
    end

    attribute :thumbnail, :integer do
      public? true
      default 0
      allow_nil? false

      description "Flag indicating whether a thumbnail image was generated for this file (e.g., 1 for yes, 0 for no)."
    end
  end
end
