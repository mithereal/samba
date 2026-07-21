defmodule PhpBB.Domain do
  use Ash.Domain,
    otp_app: :samba

  resources do
    resource PhpBB.AuthAccess
    resource PhpBB.BanList
    resource PhpBB.Categories
    resource PhpBB.Config
    resource PhpBB.Confirm
    resource PhpBB.Disallow
    resource PhpBB.FaqItem
    resource PhpBB.ForumPrune
    resource PhpBB.Forums
    resource PhpBB.Groups
    resource PhpBB.Page
    resource PhpBB.Posts
    resource PhpBB.PostsText
    resource PhpBB.Privmsgs
    resource PhpBB.PrivmsgsText
    resource PhpBB.Ranks
    resource PhpBB.SearchResults
    resource PhpBB.SearchWordlist
    resource PhpBB.SearchWordmatch
    resource PhpBB.Sessions
    resource PhpBB.SessionsKeys
    resource PhpBB.Smiles
    resource PhpBB.Themes
    resource PhpBB.ThemesName
    resource PhpBB.Topics
    resource PhpBB.TopicsWatch
    resource PhpBB.UserGroup
    resource PhpBB.Users
    resource PhpBB.VoteDesc
    resource PhpBB.VoteResults
    resource PhpBB.VoteVoters
    resource PhpBB.Words
  end
end
