defmodule PhpBB.DataDumpLoader do
  @moduledoc """
  Streams legacy phpBB database dump files for all defined Ash resources
  and routes them directly into their respective Ingester pipelines.
  Example
  PhpBB.DataDumpLoader.import_config_csv("priv/data/phpbb_config.csv")
  PhpBB.DataDumpLoader.import_categories_csv("priv/data/phpbb_categories.csv")
  PhpBB.DataDumpLoader.import_forums_csv("priv/data/phpbb_forums.csv")

  # Import users and groups
  PhpBB.DataDumpLoader.import_groups_csv("priv/data/phpbb_groups.csv")
  PhpBB.DataDumpLoader.import_users_csv("priv/data/phpbb_users.csv")

  # Import content data
  PhpBB.DataDumpLoader.import_topics_csv("priv/data/phpbb_topics.csv")
  PhpBB.DataDumpLoader.import_posts_csv("priv/data/phpbb_posts.csv")
  PhpBB.DataDumpLoader.import_posts_text_csv("priv/data/phpbb_posts_text.csv")
  """

  alias PhpBB.Crawler.Ingester

  @doc """
  Generic runner to stream any CSV dump file and pass it to an ingester function.
  """
  def import_csv(file_path, ingester_fun, mapper) do
    file_path
    |> File.stream!()
    |> PhpBB.CSVParser.stream_decoder(skip_headers: true)
    |> Stream.map(mapper)
    |> ingester_fun.()
  end

  def import_auth_access_csv(file_path) do
    import_csv(file_path, &Ingester.stream_auth_access/1, fn [group_id, forum_id, auth_view, auth_read, auth_post, auth_reply, auth_edit, auth_delete, auth_vote, auth_pollcreate, auth_attachments | _rest] ->
      %{
        group_id: String.to_integer(group_id),
        forum_id: String.to_integer(forum_id),
        auth_view: String.to_integer(auth_view),
        auth_read: String.to_integer(auth_read),
        auth_post: String.to_integer(auth_post),
        auth_reply: String.to_integer(auth_reply),
        auth_edit: String.to_integer(auth_edit),
        auth_delete: String.to_integer(auth_delete),
        auth_vote: String.to_integer(auth_vote),
        auth_pollcreate: String.to_integer(auth_pollcreate),
        auth_attachments: String.to_integer(auth_attachments)
      }
    end)
  end

  def import_ban_list_csv(file_path) do
    import_csv(file_path, &Ingester.stream_ban_list/1, fn [ban_id, ban_userid, ban_ip, ban_email | _rest] ->
      %{
        ban_id: String.to_integer(ban_id),
        ban_userid: String.to_integer(ban_userid),
        ban_ip: ban_ip,
        ban_email: ban_email
      }
    end)
  end

  def import_categories_csv(file_path) do
    import_csv(file_path, &Ingester.stream_categories/1, fn [cat_id, cat_title, cat_order | _rest] ->
      %{
        cat_id: String.to_integer(cat_id),
        cat_title: cat_title,
        cat_order: String.to_integer(cat_order)
      }
    end)
  end

  def import_config_csv(file_path) do
    import_csv(file_path, &Ingester.stream_config/1, fn [config_name, config_value, dynamic | _rest] ->
      %{
        config_name: config_name,
        config_value: config_value,
        dynamic: String.to_integer(dynamic)
      }
    end)
  end

  def import_confirm_csv(file_path) do
    import_csv(file_path, &Ingester.stream_confirm/1, fn [confirm_id, session_id, code | _rest] ->
      %{
        confirm_id: confirm_id,
        session_id: session_id,
        code: code
      }
    end)
  end

  def import_disallow_csv(file_path) do
    import_csv(file_path, &Ingester.stream_disallow/1, fn [disallow_id, disallow_username | _rest] ->
      %{
        disallow_id: String.to_integer(disallow_id),
        disallow_username: disallow_username
      }
    end)
  end

  def import_forum_prune_csv(file_path) do
    import_csv(file_path, &Ingester.stream_forum_prune/1, fn [prune_id, forum_id, prune_days, prune_freq | _rest] ->
      %{
        prune_id: String.to_integer(prune_id),
        forum_id: String.to_integer(forum_id),
        prune_days: String.to_integer(prune_days),
        prune_freq: String.to_integer(prune_freq)
      }
    end)
  end

  def import_forums_csv(file_path) do
    import_csv(file_path, &Ingester.stream_forums/1, fn [forum_id, cat_id, forum_name, forum_desc, forum_status, forum_order, forum_posts, forum_topics, forum_last_post_id, prune_enable | _rest] ->
      %{
        forum_id: String.to_integer(forum_id),
        cat_id: String.to_integer(cat_id),
        forum_name: forum_name,
        forum_desc: forum_desc,
        forum_status: String.to_integer(forum_status),
        forum_order: String.to_integer(forum_order),
        forum_posts: String.to_integer(forum_posts),
        forum_topics: String.to_integer(forum_topics),
        forum_last_post_id: String.to_integer(forum_last_post_id),
        prune_enable: String.to_integer(prune_enable)
      }
    end)
  end

  def import_groups_csv(file_path) do
    import_csv(file_path, &Ingester.stream_groups/1, fn [group_id, group_type, group_name, group_description, group_moderator, group_single_user | _rest] ->
      %{
        group_id: String.to_integer(group_id),
        group_type: String.to_integer(group_type),
        group_name: group_name,
        group_description: group_description,
        group_moderator: String.to_integer(group_moderator),
        group_single_user: String.to_integer(group_single_user)
      }
    end)
  end

  def import_posts_csv(file_path) do
    import_csv(file_path, &Ingester.stream_posts/1, fn [post_id, topic_id, forum_id, poster_id, post_time, poster_ip, post_update | _rest] ->
      %{
        post_id: String.to_integer(post_id),
        topic_id: String.to_integer(topic_id),
        forum_id: String.to_integer(forum_id),
        poster_id: String.to_integer(poster_id),
        post_time: String.to_integer(post_time),
        poster_ip: poster_ip,
        post_update: String.to_integer(post_update)
      }
    end)
  end

  def import_posts_text_csv(file_path) do
    import_csv(file_path, &Ingester.stream_posts_text/1, fn [post_id, bbcode_uid, post_subject, post_text | _rest] ->
      %{
        post_id: String.to_integer(post_id),
        bbcode_uid: bbcode_uid,
        post_subject: post_subject,
        post_text: post_text
      }
    end)
  end

  def import_privmsgs_csv(file_path) do
    import_csv(file_path, &Ingester.stream_privmsgs/1, fn [privmsgs_id, privmsgs_type, privmsgs_subject, privmsgs_from_userid, privmsgs_to_userid, privmsgs_date, privmsgs_ip, privmsgs_enable_bbcode, privmsgs_enable_html, privmsgs_enable_smilies, privmsgs_attach_sig | _rest] ->
      %{
        privmsgs_id: String.to_integer(privmsgs_id),
        privmsgs_type: String.to_integer(privmsgs_type),
        privmsgs_subject: privmsgs_subject,
        privmsgs_from_userid: String.to_integer(privmsgs_from_userid),
        privmsgs_to_userid: String.to_integer(privmsgs_to_userid),
        privmsgs_date: String.to_integer(privmsgs_date),
        privmsgs_ip: privmsgs_ip,
        privmsgs_enable_bbcode: String.to_integer(privmsgs_enable_bbcode),
        privmsgs_enable_html: String.to_integer(privmsgs_enable_html),
        privmsgs_enable_smilies: String.to_integer(privmsgs_enable_smilies),
        privmsgs_attach_sig: String.to_integer(privmsgs_attach_sig)
      }
    end)
  end

  def import_privmsgs_text_csv(file_path) do
    import_csv(file_path, &Ingester.stream_privmsgs_text/1, fn [privmsgs_text_id, privmsgs_bbcode_uid, privmsgs_text | _rest] ->
      %{
        privmsgs_text_id: String.to_integer(privmsgs_text_id),
        privmsgs_bbcode_uid: privmsgs_bbcode_uid,
        privmsgs_text: privmsgs_text
      }
    end)
  end

  def import_ranks_csv(file_path) do
    import_csv(file_path, &Ingester.stream_ranks/1, fn [rank_id, rank_title, rank_min, rank_special, rank_image | _rest] ->
      %{
        rank_id: String.to_integer(rank_id),
        rank_title: rank_title,
        rank_min: String.to_integer(rank_min),
        rank_special: String.to_integer(rank_special),
        rank_image: rank_image
      }
    end)
  end

  def import_search_results_csv(file_path) do
    import_csv(file_path, &Ingester.stream_search_results/1, fn [search_id, session_id, search_array | _rest] ->
      %{
        search_id: String.to_integer(search_id),
        session_id: session_id,
        search_array: search_array
      }
    end)
  end

  def import_search_wordlist_csv(file_path) do
    import_csv(file_path, &Ingester.stream_search_wordlist/1, fn [word_id, word_text, word_common | _rest] ->
      %{
        word_id: String.to_integer(word_id),
        word_text: word_text,
        word_common: String.to_integer(word_common)
      }
    end)
  end

  def import_search_wordmatch_csv(file_path) do
    import_csv(file_path, &Ingester.stream_search_wordmatch/1, fn [post_id, word_id, title_match | _rest] ->
      %{
        post_id: String.to_integer(post_id),
        word_id: String.to_integer(word_id),
        title_match: String.to_integer(title_match)
      }
    end)
  end

  def import_sessions_csv(file_path) do
    import_csv(file_path, &Ingester.stream_sessions/1, fn [session_id, session_user_id, session_start, session_time, session_ip, session_logged_in, session_page | _rest] ->
      %{
        session_id: session_id,
        session_user_id: String.to_integer(session_user_id),
        session_start: String.to_integer(session_start),
        session_time: String.to_integer(session_time),
        session_ip: session_ip,
        session_logged_in: String.to_integer(session_logged_in),
        session_page: String.to_integer(session_page)
      }
    end)
  end

  def import_sessions_keys_csv(file_path) do
    import_csv(file_path, &Ingester.stream_sessions_keys/1, fn [key_id, user_id, last_ip, last_login | _rest] ->
      %{
        key_id: key_id,
        user_id: String.to_integer(user_id),
        last_ip: last_ip,
        last_login: String.to_integer(last_login)
      }
    end)
  end

  def import_smiles_csv(file_path) do
    import_csv(file_path, &Ingester.stream_smiles/1, fn [smiles_id, code, smile_url, emoticon | _rest] ->
      %{
        smiles_id: String.to_integer(smiles_id),
        code: code,
        smile_url: smile_url,
        emoticon: emoticon
      }
    end)
  end

  def import_themes_csv(file_path) do
    import_csv(file_path, &Ingester.stream_themes/1, fn [themes_id, template_name, style_name, head_stylesheet, body_background, body_bgcolor, tr_color1, tr_color2, tr_class1, tr_class2, th_color, th_class, td_color1, td_color2, td_class1, td_class2 | _rest] ->
      %{
        themes_id: String.to_integer(themes_id),
        template_name: template_name,
        style_name: style_name,
        head_stylesheet: head_stylesheet,
        body_background: body_background,
        body_bgcolor: body_bgcolor,
        tr_color1: tr_color1,
        tr_color2: tr_color2,
        tr_class1: tr_class1,
        tr_class2: tr_class2,
        th_color: th_color,
        th_class: th_class,
        td_color1: td_color1,
        td_color2: td_color2,
        td_class1: td_class1,
        td_class2: td_class2
      }
    end)
  end

  def import_themes_name_csv(file_path) do
    import_csv(file_path, &Ingester.stream_themes_name/1, fn [themes_id, themes_name | _rest] ->
      %{
        themes_id: String.to_integer(themes_id),
        themes_name: themes_name
      }
    end)
  end

  def import_topics_csv(file_path) do
    import_csv(file_path, &Ingester.stream_topics/1, fn [topic_id, forum_id, topic_title, topic_poster, topic_time, topic_views, topic_replies, topic_status, topic_vote, topic_type, topic_first_post_id, topic_last_post_id, topic_moved_id | _rest] ->
      %{
        topic_id: String.to_integer(topic_id),
        forum_id: String.to_integer(forum_id),
        topic_title: topic_title,
        topic_poster: String.to_integer(topic_poster),
        topic_time: String.to_integer(topic_time),
        topic_views: String.to_integer(topic_views),
        topic_replies: String.to_integer(topic_replies),
        topic_status: String.to_integer(topic_status),
        topic_vote: String.to_integer(topic_vote),
        topic_type: String.to_integer(topic_type),
        topic_first_post_id: String.to_integer(topic_first_post_id),
        topic_last_post_id: String.to_integer(topic_last_post_id),
        topic_moved_id: String.to_integer(topic_moved_id)
      }
    end)
  end

  def import_topics_watch_csv(file_path) do
    import_csv(file_path, &Ingester.stream_topics_watch/1, fn [topic_id, user_id, notify_status | _rest] ->
      %{
        topic_id: String.to_integer(topic_id),
        user_id: String.to_integer(user_id),
        notify_status: String.to_integer(notify_status)
      }
    end)
  end

  def import_user_group_csv(file_path) do
    import_csv(file_path, &Ingester.stream_user_group/1, fn [group_id, user_id, user_pending | _rest] ->
      %{
        group_id: String.to_integer(group_id),
        user_id: String.to_integer(user_id),
        user_pending: String.to_integer(user_pending)
      }
    end)
  end

  def import_users_csv(file_path) do
    import_csv(file_path, &Ingester.stream_users/1, fn [user_id, user_active, username, user_password, user_session_time, user_session_page, user_lastvisit, user_regdate, user_level, user_posts, user_timezone, user_style, user_lang, user_dateformat, user_new_privmsg, user_unread_privmsg, user_last_privmsg, user_emailtime, user_allowviewonline, user_allowpm, user_allowavatar, user_allowbbcode, user_allowhtml, user_allowsmilies, user_allowsig, user_rank, user_avatar, user_avatar_type, user_email, user_icq, user_website, user_occ, user_interests, user_sig, user_sig_bbcode_uid, user_aim, user_yim, user_msnm, user_occ_not_used, user_occ_pass, user_actkey, user_newpasswd | _rest] ->
      %{
        user_id: String.to_integer(user_id),
        user_active: String.to_integer(user_active),
        username: username,
        user_password: user_password,
        user_session_time: String.to_integer(user_session_time),
        user_session_page: String.to_integer(user_session_page),
        user_lastvisit: String.to_integer(user_lastvisit),
        user_regdate: String.to_integer(user_regdate),
        user_level: String.to_integer(user_level),
        user_posts: String.to_integer(user_posts),
        user_timezone: String.to_integer(user_timezone),
        user_style: String.to_integer(user_style),
        user_lang: user_lang,
        user_dateformat: user_dateformat,
        user_new_privmsg: String.to_integer(user_new_privmsg),
        user_unread_privmsg: String.to_integer(user_unread_privmsg),
        user_last_privmsg: String.to_integer(user_last_privmsg),
        user_emailtime: String.to_integer(user_emailtime),
        user_allowviewonline: String.to_integer(user_allowviewonline),
        user_allowpm: String.to_integer(user_allowpm),
        user_allowavatar: String.to_integer(user_allowavatar),
        user_allowbbcode: String.to_integer(user_allowbbcode),
        user_allowhtml: String.to_integer(user_allowhtml),
        user_allowsmilies: String.to_integer(user_allowsmilies),
        user_allowsig: String.to_integer(user_allowsig),
        user_rank: String.to_integer(user_rank),
        user_avatar: user_avatar,
        user_avatar_type: String.to_integer(user_avatar_type),
        user_email: user_email,
        user_icq: user_icq,
        user_website: user_website,
        user_occ: user_occ,
        user_interests: user_interests,
        user_sig: user_sig,
        user_sig_bbcode_uid: user_sig_bbcode_uid,
        user_aim: user_aim,
        user_yim: user_yim,
        user_msnm: user_msnm,
        user_occ_not_used: String.to_integer(user_occ_not_used),
        user_occ_pass: user_occ_pass,
        user_actkey: user_actkey,
        user_newpasswd: user_newpasswd
      }
    end)
  end

  def import_vote_desc_csv(file_path) do
    import_csv(file_path, &Ingester.stream_vote_desc/1, fn [vote_id, topic_id, vote_text, vote_start, vote_length | _rest] ->
      %{
        vote_id: String.to_integer(vote_id),
        topic_id: String.to_integer(topic_id),
        vote_text: vote_text,
        vote_start: String.to_integer(vote_start),
        vote_length: String.to_integer(vote_length)
      }
    end)
  end

  def import_vote_results_csv(file_path) do
    import_csv(file_path, &Ingester.stream_vote_results/1, fn [vote_id, vote_option_id, vote_option_text, vote_result | _rest] ->
      %{
        vote_id: String.to_integer(vote_id),
        vote_option_id: String.to_integer(vote_option_id),
        vote_option_text: vote_option_text,
        vote_result: String.to_integer(vote_result)
      }
    end)
  end

  def import_vote_voters_csv(file_path) do
    import_csv(file_path, &Ingester.stream_vote_voters/1, fn [vote_id, vote_user_id, vote_user_ip | _rest] ->
      %{
        vote_id: String.to_integer(vote_id),
        vote_user_id: String.to_integer(vote_user_id),
        vote_user_ip: vote_user_ip
      }
    end)
  end

  def import_words_csv(file_path) do
    import_csv(file_path, &Ingester.stream_words/1, fn [word_id, word, replacement | _rest] ->
      %{
        word_id: String.to_integer(word_id),
        word: word,
        replacement: replacement
      }
    end)
  end
end