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
end
