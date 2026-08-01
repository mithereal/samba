defmodule Samba.Analytics.OnlineTracker do
  use GenServer

  @name __MODULE__
  @presence_topic "users:online"
  @db_persist_interval :timer.minutes(5)

  def start_link(opts \\ []) do
    GenServer.start_link(@name, opts, name: @name)
  end

  @impl true
  def init(_opts) do
    Phoenix.PubSub.subscribe(Samba.PubSub, @presence_topic)
    schedule_persist()

    # Defer looking up presence until after the supervisor finishes starting processes
    send(self(), :init_tracker)

    {:ok, %{
      max_count: 0,
      current_date: Date.utc_today(),
      recorded_at: DateTime.utc_now(),
      dirty?: false
    }}
  end

  @impl true
  def handle_info(:init_tracker, state) do
    initial_count =
      case catch_presence_list() do
        list when is_map(list) -> map_size(list)
        _ -> 0
      end

    {:noreply, %{state | max_count: initial_count}}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff"}, state) do
    now = DateTime.utc_now()
    today = DateTime.to_date(now)
    current_count = map_size(SambaWeb.Presence.list(@presence_topic))

    {max_count, current_date, dirty?} =
      cond do
        today != state.current_date ->
          persist_to_db(now, current_count)
          {current_count, today, false}

        current_count > state.max_count ->
          {current_count, state.current_date, true}

        true ->
          {state.max_count, state.current_date, state.dirty?}
      end

    {:noreply, %{state | max_count: max_count, current_date: current_date, recorded_at: now, dirty?: dirty?}}
  end

  @impl true
  def handle_info(:persist_tick, state) do
    if state.dirty? do
      persist_to_db(state.recorded_at, state.max_count)
    end

    schedule_persist()

    {:noreply, %{state | dirty?: false}}
  end

  defp catch_presence_list do
    try do
      SambaWeb.Presence.list(@presence_topic)
    rescue
      _ -> %{}
    end
  end

  defp schedule_persist do
    Process.send_after(self(), :persist_tick, @db_persist_interval)
  end

  defp persist_to_db(datetime, count) do
    Samba.Analytics.DailyStat
    |> Ash.Changeset.for_create(:upsert, %{recorded_at: datetime, total_online: count})
    |> Ash.create(domain: Samba.Analytics)
  end
end