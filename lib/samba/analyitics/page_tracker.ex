defmodule Samba.Analytics.PageTracker do
  use GenServer

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def track(user_id, location, page_name) do
    GenServer.call(__MODULE__, {:track, to_string(user_id), location, page_name})
  end

  def untrack(user_id) do
    GenServer.call(__MODULE__, {:untrack, to_string(user_id)})
  end

  def get_location(user_id) do
    GenServer.call(__MODULE__, {:get_location, to_string(user_id)})
  end

  def list_all do
    GenServer.call(__MODULE__, :list_all)
  end

  # GenServer Callbacks

  @impl true
  def init(_opts) do
    # Subscribe to Phoenix Presence diffs to automatically clean up users who lose presence
    Phoenix.PubSub.subscribe(Samba.PubSub, "users:online")

    # State stores: %{user_id => %{location: location, page_name: page_name}}
    {:ok, %{}}
  end

  @impl true
  def handle_call({:track, user_id, location, page_name}, _from, state) do
    new_state = Map.put(state, user_id, %{location: location, page_name: page_name})
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:untrack, user_id}, _from, state) do
    new_state = Map.delete(state, user_id)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:get_location, user_id}, _from, state) do
    {:reply, Map.get(state, user_id), state}
  end

  @impl true
  def handle_call(:list_all, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: payload}, state) do
    # payload.leaves contains maps of users who have completely dropped off presence
    left_user_ids =
      payload.leaves
      |> Map.keys()
      |> Enum.map(&to_string/1)

    new_state = Map.drop(state, left_user_ids)
    {:noreply, new_state}
  end
end
