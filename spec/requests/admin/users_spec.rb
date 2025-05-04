require 'rails_helper'

RSpec.describe 'Admin::Users', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in(user, scope: :user)
  end

  describe 'PATCH #update' do
    let(:valid_params) do
      {
        id: user.id,
        user: {
          first_name: 'Jane',
          last_name: 'Doe'
        }
      }
    end

    let(:invalid_params) do
      {
        id: user.id,
        user: {
          first_name: ''
        }
      }
    end

    context 'strong parameters' do
      it 'permits only the allowed attributes' do
        params = { id: user.id, user: { first_name: 'New', last_name: 'Name', confirmed_at: '2023-01-01' } }

        expect {
          put admin_user_path(user), params: params, as: :turbo_stream
        }.not_to change { user.reload.confirmed_at }
      end
    end

    context 'with valid params' do
      before { patch admin_user_path(user), params: valid_params, as: :turbo_stream }

      it 'updates the user attributes' do
        user.reload
        expect(user.first_name).to eq 'Jane'
        expect(user.last_name).to  eq 'Doe'
      end

      it 'sets a success flash.now message' do
        expect(flash.now[:success]).to eq I18n.t('admin.users.update.success')
      end

      it 'redirect_to the user show page' do
        expect(response).to redirect_to(admin_user_path(user))
      end

      it 'responds with status 200' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid params' do
      before { patch admin_user_path(user), params: invalid_params, as: :turbo_stream }

      it 'does not change the user' do
        old_attributes = user.attributes
        user.reload
        expect(user.attributes).to eq old_attributes
      end

      it 'sets a flash.now error message' do
        expect(flash.now[:error]).to start_with(I18n.t('admin.users.update.failure', errors: ''))
        expect(flash.now[:error]).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.user.first_name'), message: I18n.t('errors.messages.blank')))
      end

      it 'renders the personal_info form partial' do
        expect(response.media_type).to eq Mime[:turbo_stream]
      end

      it 'responds with status 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
