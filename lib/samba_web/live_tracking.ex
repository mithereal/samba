defmodule SambaWeb.LiveTracking do
  defmacro __using__(opts) do
    quote do
      @presence_topic "users:online"

      socket = Keyword.get(unquote(opts), :socket, nil)

      @page_name Keyword.get(unquote(opts), :page_name, nil)
      @page_url Keyword.get(unquote(opts), :page_url, nil)

      on_mount({SambaWeb.LiveTracking, :track_presence})

      @impl true
      def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
        socket = assign(socket, :online_users, list_online_users())
        {:noreply, socket}
      end

      @impl true
      def handle_params(_params, uri, socket) do
        socket = track_presence_location(socket, uri)
        {:noreply, socket}
      end

      defp track_presence_location(socket, uri) do
        if Phoenix.LiveView.connected?(socket) do
          current_user = socket.assigns[:current_user]
          user_key = if current_user, do: to_string(current_user.id), else: "guest"

          parsed_uri = URI.parse(uri)
          uri_path = parsed_uri.path || nil

          uri_path =
            case is_nil(uri_path) do
              false ->
                case socket.assigns[:page_url] do
                  url when is_binary(url) ->
                    url

                  _ ->
                    if Code.ensure_loaded?(socket.view) &&
                         function_exported?(socket.view, :page_url, 0) do
                      socket.view.page_url()
                    else
                      @page_url
                    end
                end

              true ->
                "/"
            end

          page_name =
            case socket.assigns[:page_name] do
              name when is_binary(name) ->
                name

              _ ->
                if Code.ensure_loaded?(socket.view) &&
                     function_exported?(socket.view, :page_name, 0) do
                  socket.view.page_name()
                else
                  @page_name
                end
            end

          user_meta =
            if current_user do
              %{
                username: current_user.username,
                email: to_string(current_user.email),
                location: uri_path,
                page_name: page_name,
                online_at: System.system_time(:second),
                type: :user
              }
            else
              %{
                username: "Guest",
                email: nil,
                location: uri_path,
                page_name: page_name,
                online_at: System.system_time(:second),
                type: :guest
              }
            end

          SambaWeb.Presence.update(self(), @presence_topic, user_key, user_meta)
        end

        socket
      end

      defp list_online_users() do
        SambaWeb.Presence.list(@presence_topic)
        |> Enum.map(fn {user_id, meta} -> {user_id, sanitize_meta(meta)} end)
      end

      defp list_admin_users() do
        SambaWeb.Presence.list(@presence_topic)
        |> Enum.reject(fn {user_id, meta} ->
          user_id == "guest" or Map.get(meta, :type) == :guest
        end)
        |> Enum.filter(fn {_user_id, meta} ->
          path = get_path(meta)
          path && String.starts_with?(path, "/admin")
        end)
        |> Enum.map(fn {user_id, meta} -> {user_id, meta} end)
      end

      defp list_registered_users() do
        SambaWeb.Presence.list(@presence_topic)
        |> Enum.reject(fn {user_id, meta} ->
          user_id == "guest" or Map.get(meta, :type) == :guest
        end)
        |> Enum.map(fn {user_id, meta} -> {user_id, sanitize_meta(meta)} end)
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
        |> Enum.map(fn {user_id, meta} -> {user_id, sanitize_meta(meta)} end)
      end

      # Helper to extract path safely whether location is a string or tuple
      defp get_path(%{location: path}) when is_binary(path), do: path
      defp get_path(%{location: {_title, path}}) when is_binary(path), do: path
      defp get_path(_), do: nil

      # Hides sensitive routes for public consumption
      defp sanitize_meta(meta) do
        path = get_path(meta)

        if path && sensitive_route?(path) do
          meta
          |> Map.put(:location, "/")
          |> Map.put(:page_name, "Private Area")
        else
          meta
        end
      end

      defp sensitive_route?(path) do
        sensitive_prefixes = ["/admin", "/settings", "/account", "/billing"]
        Enum.any?(sensitive_prefixes, &String.starts_with?(path, &1))
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
            "#{day_name}, today #{time_str}"

          post_date == Date.add(today, -1) ->
            "#{day_name}, yesterday #{time_str}"

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

    uri_path = url_path(socket) || session["request_path"] || session["live_socket_path"] || nil

    uri_path =
      case is_nil(uri_path) do
        false ->
          case socket.assigns[:page_url] do
            url when is_binary(url) ->
              url

            _ ->
              if Code.ensure_loaded?(socket.view) && function_exported?(socket.view, :page_url, 0) do
                socket.view.page_url()
              else
                @page_url
              end
          end

        true ->
          if Code.ensure_loaded?(socket.view) && function_exported?(socket.view, :page_url, 0) do
            socket.view.page_url()
          else
            @page_url
          end
      end

    page_name =
      case socket.assigns[:page_name] do
        name when is_binary(name) ->
          name

        _ ->
          if Code.ensure_loaded?(socket.view) && function_exported?(socket.view, :page_name, 0) do
            socket.view.page_name()
          else
            @page_name
          end
      end

    if Phoenix.LiveView.connected?(socket) do
      Phoenix.PubSub.subscribe(Samba.PubSub, presence_topic)

      user_key = if current_user, do: to_string(current_user.id), else: "guest"

      user_meta =
        if current_user do
          %{
            username: current_user.username,
            email: to_string(current_user.email),
            location: uri_path,
            page_name: page_name,
            online_at: System.system_time(:second),
            type: :user
          }
        else
          %{
            username: "Guest",
            email: nil,
            location: uri_path,
            page_name: page_name,
            online_at: System.system_time(:second),
            type: :guest
          }
        end

      {:ok, _ref} = SambaWeb.Presence.track(self(), presence_topic, user_key, user_meta)
    end

    {:cont, socket}
  end
end
