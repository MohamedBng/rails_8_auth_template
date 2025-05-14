require 'rails_helper'

RSpec.describe Admin::Roles::RolesPermissionsController, type: :request do
  let(:role) { create(:role) }
  let(:user1) { create(:user) }
  let(:permission1) { create(:permission) }
  let(:permission2) { create(:permission) }

  describe "GET /admin/roles/:role_id/roles_permissions/new" do
    context "when user is not authenticated" do
      it "redirects to sign in" do
        get new_admin_role_roles_permission_path(role)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated but lacks permission" do
      before { sign_in(user1, scope: :user) }

      it "raises CanCan::AccessDenied" do
        expect {
          get new_admin_role_roles_permission_path(role)
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    context "when user has create_roles_permission permission" do
      let(:user1) { create(:user, permissions_list: [ 'create_roles_permission' ]) }
      before { sign_in(user1, scope: :user) }

      it "returns a successful response" do
        get new_admin_role_roles_permission_path(role), xhr: true
        expect(response).to be_successful
        expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
      end

      it "filters out permissions already assigned to the role" do
        role.permissions << permission1
        get new_admin_role_roles_permission_path(role), xhr: true
        expect(assigns(:permissions_available)).not_to include(permission1)
      end
    end
  end

  describe "POST /admin/roles/:role_id/roles_permissions" do
    context "when user is not authenticated" do
      it "redirects to sign in" do
        post admin_role_roles_permissions_path(role)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated but lacks permission" do
      before { sign_in(user1, scope: :user) }

      it "raises CanCan::AccessDenied" do
        expect {
          post admin_role_roles_permissions_path(role)
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    context "when user has create_roles_permission permission" do
      let(:user1) { create(:user, permissions_list: [ 'create_roles_permission' ]) }
      before { sign_in(user1, scope: :user) }

      it "adds permissions to the role" do
        expect {
          post admin_role_roles_permissions_path(role), params: {
            role_permission: { permission_ids: [ permission1.id, permission2.id ] }
          }
        }.to change { role.permissions.count }.by(2)

        expect(response).to redirect_to(admin_role_path(role))
        expect(flash[:notice]).to eq(
          I18n.t("admin.roles.add_role_to_permissions.success", count: 2, role_name: role.name)
        )
      end

      it "handles empty permission_ids" do
        expect {
          post admin_role_roles_permissions_path(role), params: {
            role_permission: { permission_ids: [] }
          }
        }.not_to change { role.permissions.count }

        expect(response).to redirect_to(admin_role_path(role))
      end
    end
  end

  describe "DELETE /admin/roles/:role_id/roles_permissions/:id" do
    let!(:roles_permission) { create(:roles_permission, role: role, permission: permission1) }

    context "when user is not authenticated" do
      it "redirects to sign in" do
        delete admin_role_roles_permission_path(role, roles_permission)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated but lacks permission" do
      before { sign_in(user1, scope: :user) }

      it "raises CanCan::AccessDenied" do
        expect {
          delete admin_role_roles_permission_path(role, roles_permission)
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    context "when user has destroy_roles_permission permission" do
      let(:user1) { create(:user, permissions_list: [ 'destroy_roles_permission' ]) }
      before { sign_in(user1, scope: :user) }

      it "removes the permission from the role" do
        expect {
          delete admin_role_roles_permission_path(role, roles_permission)
        }.to change { role.permissions.count }.by(-1)

        expect(response).to redirect_to(admin_role_path(role))
        expect(flash[:notice]).to eq(
          I18n.t("admin.roles.remove_permission.success", role_name: role.name)
        )
      end

      context "when the roles_permission cannot be destroyed" do
        before do
          allow_any_instance_of(RolesPermission).to receive(:destroy).and_return(false)
          allow_any_instance_of(RolesPermission).to receive_message_chain(:errors, :full_messages, :to_sentence).and_return("Cannot destroy this role permission")
        end

        it "redirects back with an error message" do
          delete admin_role_roles_permission_path(role, roles_permission)

          expect(response).to redirect_to(admin_role_path(role))
          expect(flash[:alert]).to eq("Cannot destroy this role permission")
          expect(RolesPermission.exists?(roles_permission.id)).to be true
        end
      end
    end
  end
end
