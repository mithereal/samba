defmodule Samba.Analytics.OnlineTracker do
  use GenServer

  @name __MODULE__
  @save_interval :timer.minutes(5)

  def start_link(opts \\ []) do
    GenServer.start_link(@name, opts, name: @name)
  end

  @impl true
  def init(_opts) do
    schedule_save()
    {:ok, %{recorded_at: DateTime.utc_now()}}
  end

  @impl true
  def handle_info(:save_to_db, state) do
    now = DateTime.utc_now()
    presences = SambaWeb.Presence.list(SambaWeb.Endpoint)
    total_count = map_size(presences)

    persist_to_db(now, total_count)
    schedule_save()

    {:noreply, %{state | recorded_at: now}}
  end

  defp schedule_save do
    Process.send_after(self(), :save_to_db, @save_interval)
  end

  defp persist_to_db(date, count) do
    Samba.Analytics.DailyStat
    |> Ash.Changeset.for_create(:upsert, %{recorded_at: date, total_online: count})
    |> Ash.create(domain: Samba.Analytics)
  end
end
