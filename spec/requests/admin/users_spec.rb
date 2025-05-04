require 'rails_helper'

RSpec.describe 'Admin::Users', type: :request do
  let(:target_user) { create(:user) }

  describe 'GET #show' do
    context 'when the user has the read_user permission' do
      let(:user) { create(:user, permissions_list: [ 'read_user' ]) }

      before do
        sign_in(user, scope: :user)
      end

      it 'returns a successful response' do
        get admin_user_path(target_user)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the user does not have the read_user permission' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it 'raises CanCan::AccessDenied' do
        expect {
          get admin_user_path(target_user)
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end


  describe 'GET #edit' do
    context 'when the user has the update_any_user permission' do
      let(:user) { create(:user, permissions_list: [ 'update_any_user' ]) }

      before { sign_in(user, scope: :user) }

      it 'allows editing any user' do
        get edit_admin_user_path(target_user), as: :turbo_stream
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq Mime[:turbo_stream]
      end
    end

    context 'when the user has the update_own_user permission and edits themselves' do
      let(:user) { create(:user, permissions_list: [ 'update_own_user' ]) }

      before { sign_in(user, scope: :user) }

      it 'allows editing self' do
        get edit_admin_user_path(user), as: :turbo_stream
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq Mime[:turbo_stream]
      end
    end

    context 'when the user has update_own_user permission but tries to edit another user' do
      let(:user) { create(:user, permissions_list: [ 'update_own_user' ]) }

      before { sign_in(user, scope: :user) }

      it 'raises CanCan::AccessDenied' do
        expect {
          get edit_admin_user_path(target_user), as: :turbo_stream
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    context 'when the user has no update permissions' do
      let(:user) { create(:user) }

      before { sign_in(user, scope: :user) }

      it 'raises CanCan::AccessDenied' do
        expect {
          get edit_admin_user_path(target_user), as: :turbo_stream
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user has destroy_user permission and deletes another user' do
      let(:user) { create(:user, permissions_list: [ 'destroy_user' ]) }

      before { sign_in(user, scope: :user) }

      it 'deletes the user and responds successfully' do
        delete admin_user_path(target_user), as: :turbo_stream
        expect(response).to have_http_status(:ok).or have_http_status(:found)
      end
    end

    context 'when user has destroy_user permission but tries to delete themselves' do
      let(:user) { create(:user, permissions_list: [ 'destroy_user' ]) }

      before { sign_in(user, scope: :user) }

      it 'raises CanCan::AccessDenied' do
        expect {
          delete admin_user_path(user), as: :turbo_stream
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    context 'when user does not have destroy_user permission' do
      let(:user) { create(:user) }

      before { sign_in(user, scope: :user) }

      it 'raises CanCan::AccessDenied' do
        expect {
          delete admin_user_path(target_user), as: :turbo_stream
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    context 'when deletion fails' do
      let(:user) { create(:user, permissions_list: [ 'destroy_user' ]) }

      before do
        sign_in(user, scope: :user)

        error_obj = ActiveModel::Errors.new(target_user)
        error_obj.add(:base, "can't be destroyed")

        allow(target_user).to receive(:destroy).and_return(false)
        allow(target_user).to receive(:errors).and_return(error_obj)

        allow(User).to receive(:find).with(target_user.id.to_s).and_return(target_user)
      end


      it 'sets a flash error and redirects to show' do
        delete admin_user_path(target_user)
        expect(flash[:error]).to include("can't be destroyed")
        expect(response).to redirect_to(admin_user_path(target_user))
      end
    end
  end

  describe 'PATCH #update' do
    let(:valid_params) do
      {
        id: target_user.id,
        user: {
          first_name: 'Jane',
          last_name: 'Doe'
        }
      }
    end

    let(:invalid_params) do
      {
        id: target_user.id,
        user: {
          first_name: ''
        }
      }
    end

    context 'when user has update_any_user permission' do
      let(:user) { create(:user, permissions_list: [ 'update_any_user' ]) }

      before { sign_in(user, scope: :user) }

      context 'with valid params' do
        before { patch admin_user_path(target_user), params: valid_params, as: :turbo_stream }

        it 'updates the user attributes' do
          expect(target_user.reload.first_name).to eq 'Jane'
          expect(target_user.last_name).to eq 'Doe'
        end

        it 'sets a success flash.now message' do
          expect(flash.now[:success]).to eq I18n.t('admin.users.update.success')
        end

        it 'redirects to the user show page' do
          expect(response).to redirect_to(admin_user_path(target_user))
        end

        it 'responds with status 302' do
          expect(response).to have_http_status(:found)
        end
      end

      context 'with invalid params' do
        before { patch admin_user_path(target_user), params: invalid_params, as: :turbo_stream }

        it 'does not change the user' do
          old_attributes = target_user.attributes
          target_user.reload
          expect(target_user.attributes).to eq old_attributes
        end

        it 'sets a flash.now error message' do
          expect(flash.now[:error]).to include(I18n.t('admin.users.update.failure', errors: ''))
        end

        it 'renders the form partial' do
          expect(response.media_type).to eq Mime[:turbo_stream]
        end

        it 'responds with status 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when user has update_own_user permission and updates themselves' do
      let(:user) { create(:user, permissions_list: [ 'update_own_user' ]) }

      before { sign_in(user, scope: :user) }

      it 'updates successfully' do
        patch admin_user_path(user), params: valid_params.merge(id: user.id), as: :turbo_stream
        expect(user.reload.first_name).to eq 'Jane'
      end
    end

    context 'when user has update_own_user permission but tries to update another user' do
      let(:user) { create(:user, permissions_list: [ 'update_own_user' ]) }

      before { sign_in(user, scope: :user) }

      it 'raises CanCan::AccessDenied' do
        expect {
          patch admin_user_path(target_user), params: valid_params, as: :turbo_stream
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    context 'when user has no update permissions' do
      let(:user) { create(:user) }

      before { sign_in(user, scope: :user) }

      it 'raises CanCan::AccessDenied' do
        expect {
          patch admin_user_path(target_user), params: valid_params, as: :turbo_stream
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    context 'when update fails internally' do
      let(:user) { create(:user, permissions_list: [ 'update_any_user' ]) }

      before do
        sign_in(user, scope: :user)

        error_obj = ActiveModel::Errors.new(target_user)
        error_obj.add(:base, "can't be updated")

        allow(target_user).to receive(:update).and_return(false)
        allow(target_user).to receive(:errors).and_return(error_obj)
        allow(User).to receive(:find).with(target_user.id.to_s).and_return(target_user)
      end

      it 'shows the error message' do
        patch admin_user_path(target_user), params: valid_params, as: :turbo_stream
        expect(flash.now[:error]).to include("can't be updated")
      end
    end
  end
end
