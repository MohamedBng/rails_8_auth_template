# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    can :destroy, User if user.has_permission?("destroy_user")
    can :read, User if user.has_permission?("read_user")
    can :read, :dashboard if user.has_permission?("read_dashboard")
  end
end
