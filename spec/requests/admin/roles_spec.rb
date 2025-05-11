require 'rails_helper'

RSpec.describe 'Admin::Roles', type: :request do
  describe 'GET #index' do
    context 'when user is not authenticated' do
      it 'redirects to the sign in page' do
        get admin_roles_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated but not an admin' do
      let(:user) { create(:user) }
      before { sign_in(user, scope: :user) }

      it 'raises CanCan::AccessDenied' do
        expect {
          get admin_roles_path
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    context 'when user is an admin' do
      let(:admin_user) { create(:user, permissions_list: [ 'read_role' ]) }

      before do
        create_list(:role, 3)
        sign_in(admin_user, scope: :user)
        get admin_roles_path
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'renders the index template' do
        expect(response).to render_template(:index)
      end

      it 'assigns @roles' do
        expect(assigns(:roles)).not_to be_nil
        expect(assigns(:roles).size).to eq(Role.count)
      end

      it 'includes users_count for each role' do
        assigns(:roles).each do |role|
          expect(role.attributes).to include('users_count')
          expect(role.users_count.to_i).to eq(role.users.size)
        end
      end
    end
  end

  describe 'GET #new' do
    context 'when user is not authenticated' do
      it 'redirects to the sign in page' do
        get new_admin_role_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated but does not have create_role permission' do
      let(:user) { create(:user) }
      before { sign_in(user, scope: :user) }

      it 'raises CanCan::AccessDenied' do
        expect {
          get new_admin_role_path
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    context 'when user is an admin with create_role permission' do
      let(:admin_user) { create(:user, permissions_list: [ 'create_role' ]) }
      before { sign_in(admin_user, scope: :user) }

      it 'returns a successful response' do
        get new_admin_role_path
        expect(response).to have_http_status(:ok)
      end

      it 'renders the new template' do
        get new_admin_role_path
        expect(response).to render_template(:new)
      end

      it 'assigns a new Role to @role' do
        get new_admin_role_path
        expect(assigns(:role)).to be_a_new(Role)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) { { role: { name: 'New Role', color: '#FF0000' } } }
    let(:invalid_attributes) { { role: { name: '', color: '' } } }

    context 'when user is not authenticated' do
      it 'redirects to the sign in page' do
        post admin_roles_path, params: valid_attributes
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated but does not have create_role permission' do
      let(:user) { create(:user) }
      before { sign_in(user, scope: :user) }

      it 'raises CanCan::AccessDenied' do
        expect {
          post admin_roles_path, params: valid_attributes
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    context 'when user is an admin with create_role permission' do
      let(:admin_user) { create(:user, permissions_list: [ 'create_role' ]) }
      before { sign_in(admin_user, scope: :user) }

      context 'with valid parameters' do
        it 'creates a new Role' do
          expect {
            post admin_roles_path, params: valid_attributes
          }.to change(Role, :count).by(1)
        end

        it 'redirects to the roles list' do
          post admin_roles_path, params: valid_attributes
          expect(response).to redirect_to(admin_roles_path)
        end

        it 'sets a success flash message' do
          post admin_roles_path, params: valid_attributes
          expect(flash[:success]).to eq(I18n.t("admin.roles.create.success"))
        end
      end

      context 'with invalid parameters' do
        it 'does not create a new Role' do
          expect {
            post admin_roles_path, params: invalid_attributes
          }.not_to change(Role, :count)
        end

        it "re-renders the 'new' template with unprocessable_entity status" do
          post admin_roles_path, params: invalid_attributes
          expect(response).to render_template(:new)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'sets an error flash message' do
          post admin_roles_path, params: invalid_attributes
          expect(flash.now[:error]).to be_present
        end
      end
    end
  end
end
