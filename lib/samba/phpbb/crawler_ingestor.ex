defmodule PhpBB.Crawler.Ingester do
  @batch_size 100

  @doc """
  Generic helper to process streams in chunks with upsert support.
  """
  defp stream_to_resource(crawler_stream, resource, identity \\ nil) do
    crawler_stream
    |> Stream.chunk_every(@batch_size)
    |> Enum.each(fn batch ->
      Enum.each(batch, fn attrs ->
        opts = [upsert?: true]
        opts = if identity, do: Keyword.put(opts, :upsert_identity, identity), else: opts

        resource
        |> Ash.Changeset.for_create(:create, attrs)
        |> Ash.create!(opts)
      end)
    end)
  end

  def stream_auth_access(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.AuthAccess)
  end

  def stream_ban_list(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.BanList)
  end

  def stream_categories(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.Categories)
  end

  def stream_config(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.Config)
  end

  def stream_confirm(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.Confirm)
  end

  def stream_disallow(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.Disallow)
  end

  def stream_forum_prune(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.ForumPrune)
  end

  def stream_forums(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.Forums)
  end

  def stream_groups(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.Groups)
  end

  def stream_posts(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.Posts)
  end

  def stream_posts_text(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.PostsText)
  end

  def stream_privmsgs(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.Privmsgs)
  end

  def stream_privmsgs_text(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.PrivmsgsText)
  end

  def stream_ranks(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.Ranks)
  end

  def stream_search_results(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.SearchResults)
  end

  def stream_search_wordlist(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.SearchWordlist)
  end

  def stream_search_wordmatch(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.SearchWordmatch)
  end

  def stream_sessions(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.Sessions)
  end

  def stream_sessions_keys(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.SessionsKeys)
  end

  def stream_smiles(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.Smiles)
  end

  def stream_themes(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.Themes)
  end

  def stream_themes_name(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.ThemesName)
  end

  def stream_topics(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.Topics)
  end

  def stream_topics_watch(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.TopicsWatch)
  end

  def stream_user_group(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.UserGroup, :unique_name)
  end

  def stream_users(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.Users)
  end

  def stream_vote_desc(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.VoteDesc, :unique_name)
  end

  def stream_vote_results(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.VoteResults)
  end

  def stream_vote_voters(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.VoteVoters, :unique_name)
  end

  def stream_words(crawler_stream) do
    stream_to_resource(crawler_stream, PhpBB.Words)
  end
end
