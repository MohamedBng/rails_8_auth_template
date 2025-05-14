require 'rails_helper'

RSpec.describe "Admin::Roles::UserRolesController", type: :request do
  let(:role) { create(:role) }
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }

  describe "POST /admin/roles/:role_id/user_roles" do
    let(:valid_params) { { role_user: { user_ids: [ user1.id, user2.id ] } } }
    let(:empty_params) { { role_user: { user_ids: [] } } }
    let(:invalid_user_params) { { role_user: { user_ids: [ user1.id, 'invalid-id', user2.id ] } } }

    context "when user is not authenticated" do
      it "redirects to the sign in page" do
        post admin_role_user_roles_path(role), params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated but does not have create_users_role permission" do
      let(:user) { create(:user) }
      before { sign_in(user, scope: :user) }

      it "raises CanCan::AccessDenied" do
        expect {
          post admin_role_user_roles_path(role), params: valid_params
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    context "when user has create_users_role permission" do
      let(:user) { create(:user, permissions_list: [ 'create_users_role' ]) }
      before { sign_in(user, scope: :user) }

      it "adds the selected users to the role" do
        post admin_role_user_roles_path(role), params: valid_params

        expect(response).to redirect_to(admin_role_path(role))
        expect(flash[:notice]).to eq(I18n.t("admin.roles.add_role_to_users.success", count: 2, role_name: role.name))
        role.reload
        expect(role.users).to include(user1, user2)
      end

      it "ignores invalid ids and adds only valid users" do
        expect {
          post admin_role_user_roles_path(role), params: invalid_user_params
        }.to change { role.users.count }.by(2)

        expect(response).to redirect_to(admin_role_path(role))
        role.reload
        expect(role.users).to include(user1, user2)
        expect(role.users.count).to eq(2)
      end
    end
  end
end
