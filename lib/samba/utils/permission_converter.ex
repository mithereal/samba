defmodule BBCode.PhpBb2PermissionConverter do
  @moduledoc """
  Automatically resolves phpBB 2 forum permissions, dynamically expanding
  AUTH_ACL (value = 2) settings by reading custom group access override rows
  and mapping them to ash-phoenix-starter format.
  """

  @auth_levels %{
    0 => :guests,
    1 => :registered,
    2 => :acl_restricted,
    3 => :moderators,
    5 => :administrators
  }

  def convert_forum_permissions(forum_row, auth_access_rows \\ [], group_id_to_name_map \\ %{}) do
    %{
      forum_id: forum_row[:forum_id],
      forum_name: forum_row[:forum_name],
      permissions: map_auth_fields(forum_row, auth_access_rows, group_id_to_name_map)
    }
  end

  defp map_auth_fields(row, auth_access_rows, group_map) do
    [
      translate_auth(:view, row[:auth_view], :auth_view, auth_access_rows, group_map),
      translate_auth(:read, row[:auth_read], :auth_read, auth_access_rows, group_map),
      translate_auth(:post, row[:auth_post], :auth_post, auth_access_rows, group_map),
      translate_auth(:reply, row[:auth_reply], :auth_reply, auth_access_rows, group_map),
      translate_auth(:sticky, row[:auth_sticky], :auth_sticky, auth_access_rows, group_map),
      translate_auth(:announce, row[:auth_announce], :auth_announce, auth_access_rows, group_map)
    ]
    |> List.flatten()
    |> Enum.uniq()
  end

  defp translate_auth(action_type, level, db_column, auth_access_rows, group_map) do
    permission_name = permission_string(action_type)
    role = Map.get(@auth_levels, level, :administrators)

    case role do
      :acl_restricted ->
        auth_access_rows
        |> Enum.filter(fn access -> Map.get(access, db_column) == 1 end)
        |> Enum.map(fn access ->
          group_id = access[:group_id]
          group_name = Map.get(group_map, group_id, "CustomGroup_#{group_id}")
          %{role: group_name, permission: permission_name}
        end)

      :guests ->
        build_tier_rules(
          ["Guests", "Registered", "Moderators", "Administrators"],
          permission_name
        )

      :registered ->
        build_tier_rules(["Registered", "Moderators", "Administrators"], permission_name)

      :moderators ->
        build_tier_rules(["Moderators", "Administrators"], permission_name)

      _ ->
        build_tier_rules(["Administrators"], permission_name)
    end
  end

  defp permission_string(:view), do: "forum:view"
  defp permission_string(:read), do: "forum:read"
  defp permission_string(:post), do: "topic:create"
  defp permission_string(:reply), do: "post:create"
  defp permission_string(:sticky), do: "topic:create_sticky"
  defp permission_string(:announce), do: "topic:create_announcement"

  defp build_tier_rules(roles, permission_name) do
    Enum.map(roles, fn role -> %{role: role, permission: permission_name} end)
  end
end
