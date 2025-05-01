# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    can :delete, User if user.has_permission?("delete_user")
    can :read, User if user.has_permission?("read_user")
  end
end
