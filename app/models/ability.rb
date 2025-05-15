# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    can :create, User if user.has_permission?("create_user")
    can :read, User if user.has_permission?("read_user")
    can :read, :dashboard if user.has_permission?("read_dashboard")
    can :read, Role if user.has_permission?("read_role")
    can :create, Role if user.has_permission?("create_role")
    can :update, Role if user.has_permission?("update_role")
    can :destroy, UsersRole if user.has_permission?("destroy_users_role")
    can :create, UsersRole if user.has_permission?("create_users_role")
    can :create, RolesPermission if user.has_permission?("create_roles_permission")
    can :destroy, RolesPermission if user.has_permission?("destroy_roles_permission")

    if user.has_permission?("update_any_user")
      can [:update, :delete_profile_image], User
    elsif user.has_permission?("update_own_user")
      can [:update, :delete_profile_image], User, id: user.id
    end    

    can :destroy, User do |target_user|
      true if user.has_permission?("destroy_user") && user != target_user
    end
  end
end
