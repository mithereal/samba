defmodule PhpBB.Ranks do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_ranks"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :rank_id,
        :rank_title,
        :rank_min,
        :rank_special,
        :rank_image
      ]
    end
  end

  attributes do
    attribute :rank_id, :integer do
      public? true
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :rank_title, :string do
      allow_nil? false
      default " "
      public? true
    end

    attribute :rank_min, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :rank_special, :integer do
      constraints min: -32768, max: 32767
      default 0
      allow_nil? false
      public? true

      description "0 (Normal / Post-Count Rank): This is a standard, automated rank. Users automatically graduate to this rank once their total post count crosses a specific threshold defined in the database (stored in rank_min)."
    end

    attribute :rank_image, :string do
      allow_nil? true
      public? true
    end
  end

  def seed_default_ranks do
    default_ranks = [
      %{rank_title: "Site Admin", rank_min: -1, rank_special: 1, rank_image: ""},
      %{rank_title: "Junior Member", rank_min: 0, rank_special: false, rank_image: ""},
      %{rank_title: "Member", rank_min: 20, rank_special: false, rank_image: ""},
      %{rank_title: "Senior Member", rank_min: 50, rank_special: false, rank_image: ""}
    ]

    Enum.each(default_ranks, fn rank_attrs ->
      case __MODULE__
           |> Ash.Changeset.for_create(:create, rank_attrs)
           |> Ash.create(domain: PhpBB.Domain, authorize?: false) do
        {:ok, rank} ->
          IO.puts("Successfully created rank: #{rank.rank_title}")

        {:error, error} ->
          IO.inspect(error, label: "Failed to create rank #{rank_attrs.rank_title}")
      end
    end)
  end
end
