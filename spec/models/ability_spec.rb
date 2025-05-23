require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  subject(:ability) { Ability.new(user) }

  let(:target_user) { create(:user) }

  context "when user has 'destroy_user' permission" do
    let(:user) { create(:user) }

    before do
      permission = create(:permission, name: "destroy_user")
      user.roles.first.permissions << permission
    end

    it "can destroy other users" do
      expect(ability).to be_able_to(:destroy, target_user)
    end

    it "cannot read users unless also has 'read_user'" do
      expect(ability).not_to be_able_to(:read, target_user)
    end

    it "cannot destroy themselves" do
      expect(ability).not_to be_able_to(:destroy, user)
    end
  end


  context "when user has 'read_user' permission only" do
    let(:user) { create(:user) }

    before do
      permission = create(:permission, name: "read_user")
      user.roles.first.permissions << permission
    end

    it "can read users" do
      expect(ability).to be_able_to(:read, target_user)
    end

    it "cannot destroy users" do
      expect(ability).not_to be_able_to(:destroy, target_user)
    end
  end

  context "when user has both 'read_user' and 'destroy_user' permissions" do
    let(:user) { create(:user) }

    before do
      role = user.roles.first
      role.permissions << create(:permission, name: "read_user")
      role.permissions << create(:permission, name: "destroy_user")
    end

    it "can read and destroy users" do
      expect(ability).to be_able_to(:read, target_user)
      expect(ability).to be_able_to(:destroy, target_user)
    end
  end

  context "when user has no permissions" do
    let(:user) { create(:user) }

    it "cannot read or destroy users" do
      expect(ability).not_to be_able_to(:read, target_user)
      expect(ability).not_to be_able_to(:destroy, target_user)
    end
  end

  context "when user has 'read_dashboard' permission" do
    let(:user) { create(:user) }

    before do
      permission = create(:permission, name: "read_dashboard")
      user.roles.first.permissions << permission
    end

    it "can read the dashboard" do
      expect(ability).to be_able_to(:read, :dashboard)
    end

    it "cannot destroy users" do
      expect(ability).not_to be_able_to(:destroy, target_user)
      expect(ability).not_to be_able_to(:read, target_user)
    end
  end

  context "when user has 'update_any_user' permission" do
    let(:user) { create(:user) }

    before do
      permission = create(:permission, name: "update_any_user")
      user.roles.first.permissions << permission
    end

    it "can update any user" do
      expect(ability).to be_able_to(:update, target_user)
      expect(ability).to be_able_to(:update, user)
    end

    it "can delete any user's profile image" do
      expect(ability).to be_able_to(:delete_profile_image, user)
      expect(ability).to be_able_to(:delete_profile_image, target_user)
    end
  end

  context "when user has 'update_own_user' permission" do
    let(:user) { create(:user) }

    before do
      permission = create(:permission, name: "update_own_user")
      user.roles.first.permissions << permission
    end

    it "can update themselves" do
      expect(ability).to be_able_to(:update, user)
    end

    it "can delete own profile image" do
      expect(ability).to be_able_to(:delete_profile_image, user)
    end

    it "cannot update other users" do
      expect(ability).not_to be_able_to(:update, target_user)
    end

    it "cannot delete other users' profile images" do
      expect(ability).not_to be_able_to(:delete_profile_image, target_user)
    end
  end

  context "when user has no update permissions" do
    let(:user) { create(:user) }

    it "cannot update any user" do
      expect(ability).not_to be_able_to(:update, target_user)
      expect(ability).not_to be_able_to(:update, user)
    end

    it "cannot delete any user's profile image" do
      expect(ability).not_to be_able_to(:delete_profile_image, target_user)
      expect(ability).not_to be_able_to(:delete_profile_image, user)
    end
  end

  context "with create_user permission" do
    let(:user) { create(:user, permissions_list: [ 'create_user' ]) }
    let(:ability) { Ability.new(user) }

    it "allows creating a new user" do
      expect(ability).to be_able_to(:create, User)
    end
  end

  context "without create_user permission" do
    let(:user) { create(:user) }
    let(:ability) { Ability.new(user) }

    it "prevents creating a new user" do
      expect(ability).not_to be_able_to(:create, User)
    end
  end

  context "with read_role permission" do
    let(:user) { create(:user, permissions_list: [ 'read_role' ]) }
    let(:ability) { Ability.new(user) }

    it "allows reading roles" do
      expect(ability).to be_able_to(:read, Role)
    end
  end

  context "without read_role permission" do
    let(:user) { create(:user) }
    let(:ability) { Ability.new(user) }

    it "prevents reading roles" do
      expect(ability).not_to be_able_to(:read, Role)
    end
  end

  context "with create_role permission" do
    let(:user) { create(:user, permissions_list: [ 'create_role' ]) }

    it "allows creating a new role" do
      expect(ability).to be_able_to(:create, Role)
    end
  end

  context "with create_roles_permission permission" do
    let(:user) { create(:user, permissions_list: [ 'create_roles_permission' ]) }
    let(:role) { create(:role) }

    it "allows creating a new roles_permission" do
      expect(ability).to be_able_to(:create, RolesPermission.new(role: role))
    end

    it "prevents creating a roles_permission without permission" do
      user.roles.first.permissions.clear
      expect(ability).not_to be_able_to(:create, RolesPermission.new(role: role))
    end
  end

  context "with destroy_roles_permission permission" do
    let(:user) { create(:user, permissions_list: [ 'destroy_roles_permission' ]) }
    let(:role) { create(:role) }
    let(:roles_permission) { create(:roles_permission, role: role) }

    it "allows destroying a roles_permission" do
      expect(ability).to be_able_to(:destroy, roles_permission)
    end

    it "prevents destroying a roles_permission without permission" do
      user.roles.first.permissions.clear
      expect(ability).not_to be_able_to(:destroy, roles_permission)
    end
  end

  context "without create_role permission" do
    let(:user) { create(:user) }

    it "prevents creating a new role" do
      expect(ability).not_to be_able_to(:create, Role)
    end
  end

  context "with create_users_role permission" do
    let(:user) { create(:user, permissions_list: [ 'create_users_role' ]) }

    it "allows creating user roles" do
      expect(ability).to be_able_to(:create, UsersRole)
    end
  end

  context "without create_users_role permission" do
    let(:user) { create(:user) }

    it "prevents creating user roles" do
      expect(ability).not_to be_able_to(:create, UsersRole)
    end
  end

  context "with destroy_users_role permission" do
    let(:user) { create(:user, permissions_list: [ 'destroy_users_role' ]) }

    it "allows destroying user roles" do
      expect(ability).to be_able_to(:destroy, UsersRole)
    end
  end

  context "without destroy_users_role permission" do
    let(:user) { create(:user) }

    it "prevents destroying user roles" do
      expect(ability).not_to be_able_to(:destroy, UsersRole)
    end
  end

  context "with update_role permission" do
    let(:user) { create(:user, permissions_list: [ 'update_role' ]) }

    it "allows updating roles" do
      expect(ability).to be_able_to(:update, Role)
    end
  end

  context "without update_role permission" do
    let(:user) { create(:user) }

    it "prevents updating roles" do
      expect(ability).not_to be_able_to(:update, Role)
    end
  end
end
