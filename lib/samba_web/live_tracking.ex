defmodule SambaWeb.LiveTracking do
  defmacro __using__(opts) do
    quote do
      @presence_topic "users:online"

      socket = Keyword.get(unquote(opts), :socket, nil)

      on_mount({SambaWeb.LiveTracking, :track_presence})

      @impl true
      def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
        socket = assign(socket, :online_users, list_online_users())
        {:noreply, socket}
      end

      defp list_online_users() do
        SambaWeb.Presence.list(@presence_topic)
        |> Enum.map(fn {user_id, meta} -> {user_id, meta} end)
      end

      defp list_admin_users() do
        SambaWeb.Presence.list(@presence_topic)
        |> Enum.reject(fn {user_id, meta} ->
          user_id == "guest" or Map.get(meta, :type) == :guest
        end)
        |> Enum.map(fn {user_id, meta} -> {user_id, meta} end)
      end

      defp list_registered_users() do
        SambaWeb.Presence.list(@presence_topic)
        |> Enum.reject(fn {user_id, meta} ->
          user_id == "guest" or Map.get(meta, :type) == :guest
        end)
        |> Enum.map(fn {user_id, meta} -> {user_id, meta} end)
      end

      defp list_forum_online_users() do
        SambaWeb.Presence.list(@presence_topic)
        |> Enum.reject(fn {user_id, meta} ->
          user_id == "guest" or Map.get(meta, :type) == :guest
        end)
        |> Enum.map(fn {user_id, _meta} -> user_id end)
      end

      defp list_chat_users() do
        SambaWeb.Presence.list("users:chat")
        |> Enum.map(fn {user_id, _meta} -> user_id end)
      end

      defp list_guest_users() do
        SambaWeb.Presence.list(@presence_topic)
        |> Enum.filter(fn {user_id, meta} ->
          user_id == "guest" or Map.get(meta, :type) == :guest
        end)
        |> Enum.map(fn {user_id, meta} -> {user_id, meta} end)
      end

      defp format_timestamp(nil), do: ""

      defp format_timestamp(unix_timestamp)
           when is_integer(unix_timestamp) and unix_timestamp > 0 do
        post_dt = DateTime.from_unix!(unix_timestamp)
        post_date = DateTime.to_date(post_dt)
        today = Date.utc_today()

        day_name = Calendar.strftime(post_dt, "%a") |> String.downcase()
        time_str = Calendar.strftime(post_dt, "%I:%M %p") |> String.downcase()

        cond do
          post_date == today ->
            "Today #{time_str}"

          post_date == Date.add(today, -1) ->
            "Yesterday #{time_str}"

          true ->
            date_str = Calendar.strftime(post_dt, "%b %d") |> String.downcase()
            "#{day_name}, #{date_str}, #{time_str}"
        end
      end

      defp format_timestamp(_), do: ""
    end
  end

  def url_path(nil) do
    nil
  end

  def url_path(socket) do
    uri_path =
      case socket.private[:live_view_uri] do
        %URI{path: path} ->
          path

        _ ->
          nil
      end
  end

  def on_mount(:track_presence, _params, session, socket) do
    current_user = socket.assigns[:current_user]
    presence_topic = "users:online"

    if Phoenix.LiveView.connected?(socket) do
      Phoenix.PubSub.subscribe(Samba.PubSub, presence_topic)

      user_key = if current_user, do: to_string(current_user.id), else: "guest"

      user_meta =
        if current_user do
          %{
            username: current_user.username,
            online_at: System.system_time(:second)
          }
        else
          %{
            username: "Guest",
            online_at: System.system_time(:second)
          }
        end

      {:ok, _ref} = SambaWeb.Presence.track(self(), presence_topic, user_key, user_meta)
    end

    {:cont, socket}
  end
end
