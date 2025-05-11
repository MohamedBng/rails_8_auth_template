# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    can :create, User if user.has_permission?("create_user")
    can :read, User if user.has_permission?("read_user")
    can :read, :dashboard if user.has_permission?("read_dashboard")
    can :read, Role if user.has_permission?("read_role")

    can :update, User do |target_user|
      if user.has_permission?("update_any_user")
        true
      elsif user.has_permission?("update_own_user") && user == target_user
        true
      else
        false
      end
    end

    can :delete_profile_image, User do |target_user|
      if user.has_permission?("delete_profile_image")
        true
      elsif user.has_permission?("delete_own_profile_image") && user == target_user
        true
      else
        false
      end
    end

    can :destroy, User do |target_user|
      true if user.has_permission?("destroy_user") && user != target_user
    end
  end
end
