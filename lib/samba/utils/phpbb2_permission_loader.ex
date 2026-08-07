defmodule BBCode.PhpBb2PermissionLoader do
  @moduledoc """
  Handles direct queries against the legacy phpBB 2 database tables
  (phpbb_groups, phpbb_forums, phpbb_auth_access).
  """

  def fetch_group_id_map do
    case AshPhoenixStarter.Repo.query("SELECT group_id, group_name FROM phpbb_groups") do
      {:ok, %{rows: rows}} -> Map.new(rows, fn [id, name] -> {id, name} end)
      _ -> %{}
    end
  end

  def fetch_all_forums do
    query = """
    SELECT forum_id, forum_name, auth_view, auth_read, auth_post,
           auth_reply, auth_sticky, auth_announce
    FROM phpbb_forums
    """

    case AshPhoenixStarter.Repo.query(query) do
      {:ok, %{columns: columns, rows: rows}} ->
        Enum.map(rows, fn row ->
          Enum.zip(Enum.map(columns, &String.to_atom/1), row) |> Map.new()
        end)

      _ ->
        []
    end
  end

  def fetch_auth_access_for_forum(forum_id) do
    query = """
    SELECT forum_id, group_id, auth_view, auth_read, auth_post,
           auth_reply, auth_sticky, auth_announce
    FROM phpbb_auth_access
    WHERE forum_id = $1
    """

    case AshPhoenixStarter.Repo.query(query, [forum_id]) do
      {:ok, %{columns: columns, rows: rows}} ->
        Enum.map(rows, fn row ->
          Enum.zip(Enum.map(columns, &String.to_atom/1), row) |> Map.new()
        end)

      _ ->
        []
    end
  end
end
