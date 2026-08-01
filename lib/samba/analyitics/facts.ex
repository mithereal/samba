defmodule Samba.Analytics.Facts do
  use Ash.Resource,
    otp_app: :samba,
    domain: Samba.Analytics,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "facts"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :upsert do
      primary? true
      accept [:fact]
      upsert? true
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :fact, :string do
      allow_nil? false
      default ""
    end

    timestamps()
  end
end
