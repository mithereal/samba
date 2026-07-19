defmodule Samba.Accounts.User.Relationships do
  use Spark.Dsl.Fragment, of: Ash.Resource

  relationships do
    belongs_to :team, Samba.Accounts.Team do
      description "Current team object"
      source_attribute :current_team
      destination_attribute :domain
    end

    many_to_many :teams, Samba.Accounts.Team do
      through Samba.Accounts.UserTeam
      source_attribute_on_join_resource :user_id
      destination_attribute_on_join_resource :team_id
    end

    many_to_many :groups, Samba.Accounts.Group do
      through Samba.Accounts.UserGroup
      source_attribute_on_join_resource :user_id
      destination_attribute_on_join_resource :group_id
    end

    has_many :impersonations, Samba.Accounts.UserImpersonation do
      destination_attribute :impersonated_user_id
      description "Active impersonation for this user"
    end
  end
end
