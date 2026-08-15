defmodule Samba.Core.Page do
  use Ash.Resource,
      otp_app: :samba,
      domain: Elixir.Samba.Core,
      data_layer: AshPostgres.DataLayer,
      extensions: [AshOban],
      authorizers: []

  postgres do
    table "pages"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :destroy]

    read :by_title do
      argument :title, :string, allow_nil?: false
      get? true

      filter expr(title == ^arg(:title))
    end

    create :create do
      accept [:title, :slug, :content, :published?]
      primary? true
    end

    update :update do
      accept [:title, :slug, :content, :published?]
      primary? true
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
    end

    attribute :slug, :string do
      allow_nil? false
      constraints [match: ~r/^[a-z0-9-]+$/]
    end

    attribute :content, :string do
      allow_nil? false
    end

    attribute :published?, :boolean do
      default false
      allow_nil? false
    end

    timestamps()
  end

  validations do
    validate match(:slug, ~r/^[a-z0-9-]+$/), message: "must contain only lowercase letters, numbers, and hyphens"
  end

  code_interface do
    define :by_title, action: :read, get_by: [:title]
  end
end