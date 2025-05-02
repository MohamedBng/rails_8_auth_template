
require 'rails_helper'

RSpec.describe Users::GoogleOmniauthService, type: :service do
  describe '.call' do
    let(:user) { build_stubbed(:user, email: 'test@example.com', first_name: 'John', last_name: 'Doe') }

    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: '123456789',
        info: {
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name
        }
      )
    end

    let(:auth_data) do
      {
        uid: auth.uid,
        email: auth.info.email,
        first_name: auth.info.first_name,
        last_name: auth.info.last_name
      }
    end

    before do
      OmniAuth.config.test_mode = true
    end

    context 'when the user does not exist' do
      it 'creates a new user and returns Success' do
        expect {
          result = described_class.call(auth: auth_data)
          expect(result).to be_success

          created_user = result.value!
          expect(created_user.email).to eq(user.email)
          expect(created_user.first_name).to eq(user.first_name)
        }.to change(User, :count).by(1)
      end
    end

    context 'when the user already exists' do
      let!(:existing_user) do
        User.create!(
          email: user.email,
          password: 'password123',
          first_name: 'Old',
          last_name: 'User'
        )
      end

      it 'returns the existing user and updates it' do
        result = described_class.call(auth: auth_data)
        expect(result).to be_success

        updated_user = result.value!
        expect(updated_user.id).to eq(existing_user.id)
        expect(updated_user.first_name).to eq(user.first_name)
        expect(updated_user.last_name).to eq(user.last_name)
      end
    end

    context 'when saving fails' do
      before do
        allow(User).to receive(:find_or_initialize_by).and_return(User.new) # invalid user (missing required fields)
      end

      it 'returns Failure with validation errors' do
        result = described_class.call(auth: auth_data)
        expect(result).to be_failure
        expect(result.failure).to be_an(ActiveModel::Errors)
      end
    end
  end
end
