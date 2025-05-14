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

  describe "DELETE /admin/roles/:role_id/user_roles/:id" do
    let(:users_role) { UsersRole.create(user: user1, role: role) }

    context "when user is not authenticated" do
      it "redirects to the sign in page" do
        delete admin_role_user_role_path(role, users_role)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated but does not have destroy_users_role permission" do
      let(:user) { create(:user) }
      before { sign_in(user, scope: :user) }

      it "raises CanCan::AccessDenied" do
        expect {
          delete admin_role_user_role_path(role, users_role)
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    context "when user has destroy_users_role permission" do
      let(:user) { create(:user, permissions_list: [ 'destroy_users_role' ]) }
      before { sign_in(user, scope: :user) }

      it "removes the user from the role" do
        expect {
          delete admin_role_user_role_path(role, users_role)
        }.to change(UsersRole, :count).by(1)

        expect(response).to redirect_to(admin_role_path(role))
        expect(flash[:notice]).to eq(I18n.t('admin.user_roles.user_removed', role_name: role.name))
      end

      context "when the users_role cannot be destroyed" do
        it "redirects back with an error message" do
          users_role = UsersRole.create!(user: user1, role: role)
          allow(UsersRole).to receive(:find).with(users_role.id.to_s).and_return(users_role)
          allow(users_role).to receive(:destroy).and_return(false)
          allow(users_role).to receive_message_chain(:errors, :full_messages, :to_sentence).and_return("Cannot destroy this user role")

          delete admin_role_user_role_path(role, users_role)

          expect(response).to redirect_to(admin_role_path(role))
          expect(flash[:alert]).to eq("Cannot destroy this user role")
          expect(UsersRole.exists?(users_role.id)).to be true
        end
      end
    end
  end
end
