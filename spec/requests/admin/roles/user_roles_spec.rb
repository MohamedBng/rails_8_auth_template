require 'rails_helper'

RSpec.describe "Admin::Roles::UserRolesController", type: :request do
  let(:admin_user) { create(:user) }
  let(:role) { create(:role) }
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }

  before do
    sign_in(admin_user, scope: :user)
  end

  describe "POST /admin/roles/:role_id/user_roles" do
    let(:valid_params) { { role_user: { user_ids: [ user1.id, user2.id ] } } }
    let(:empty_params) { { role_user: { user_ids: [] } } }
    let(:invalid_user_params) { { role_user: { user_ids: [ user1.id, 'invalid-id', user2.id ] } } }

    context "with valid parameters" do
      it "adds the selected users to the role" do
        post admin_role_user_roles_path(role), params: valid_params

        expect(response).to redirect_to(admin_role_path(role))
        expect(flash[:notice]).to eq(I18n.t("admin.roles.users_list.add_selected_users"))
        role.reload
        expect(role.users).to include(user1, user2)
      end
    end

    context "when not authenticated" do
      before { sign_out admin_user }

      it "does not add users and redirects to sign in" do
        expect {
          post admin_role_user_roles_path(role), params: valid_params
        }.not_to change { role.users.count }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "with an empty user_ids array" do
      it "does not add any users but redirects and shows notice" do
        expect {
          post admin_role_user_roles_path(role), params: empty_params
        }.not_to change { role.users.count }

        expect(response).to redirect_to(admin_role_path(role))
        expect(flash[:notice]).to eq(I18n.t("admin.roles.users_list.add_selected_users"))
      end
    end

    context "with invalid user_ids in the array" do
      it "adds only the valid users" do
        expect {
          post admin_role_user_roles_path(role), params: invalid_user_params
        }.to change { role.users.count }.by(2)

        expect(response).to redirect_to(admin_role_path(role))
        expect(flash[:notice]).to eq(I18n.t("admin.roles.users_list.add_selected_users"))
        role.reload
        expect(role.users).to include(user1, user2)
        expect(role.users.count).to eq(2)
      end
    end
  end
end
