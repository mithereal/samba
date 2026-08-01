defmodule Samba.Analytics.DailyStat do
  use Ash.Resource,
    otp_app: :samba,
    domain: Samba.Analytics,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "daily_stats"
    repo Samba.Repo

    custom_indexes do
      index [:recorded_at], unique: true
    end
  end

  actions do
    defaults [:read, :destroy]

    create :upsert do
      primary? true
      accept [:recorded_at, :total_online]
      upsert? true
      upsert_identity :unique_recorded_at
    end

    read :max_online do
      prepare fn query, _ ->
        query
        |> Ash.Query.sort(total_online: :desc)
        |> Ash.Query.limit(1)
      end
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :recorded_at, :utc_datetime do
      allow_nil? false
    end

    attribute :total_online, :integer do
      allow_nil? false
      default 0
    end

    timestamps()
  end

  identities do
    identity :unique_recorded_at, [:recorded_at]
  end

  def seed_default_stats do
    default_stats = [
      %{total_online: 76159, recorded_at: ~U[2026-01-24 00:23:00Z]}
    ]

    Enum.each(default_stats, fn stats ->
      case Samba.Analytics.DailyStat
           |> Ash.Changeset.for_create(:upsert, stats)
           |> Ash.create(domain: Samba.Analytics, authorize?: false) do
        {:ok, _stat} ->
          IO.puts("Successfully created stats for timestamp: #{stats.recorded_at}")

        {:error, error} ->
          IO.inspect(error, label: "Failed to create stats")
      end
    end)
  end
end
