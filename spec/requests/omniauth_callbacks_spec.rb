# spec/requests/omniauth_callbacks_spec.rb
require 'rails_helper'

RSpec.describe "OmniauthCallbacks", type: :request do
  include OmniauthTestHelper

  let(:user_email) { 'test@example.com' }
  let(:user) { create(:user, email: user_email) }

  describe "Google OAuth" do
    context "when authentication is successful" do
      before do
        mock_successful_oauth(provider: :google_oauth2, email: user_email)
      end

      after do
        reset_omniauth
      end

      it "logs the user in if user already exists" do
        get user_google_oauth2_omniauth_callback_path
        follow_redirect!

        expect(response.body).to include("Successfully authenticated")
      end

      it "creates a new user if user does not exist" do
        expect {
          get user_google_oauth2_omniauth_callback_path
          follow_redirect!
        }.to change(User, :count).by(1)

        expect(response.body).to include("Successfully authenticated")
        expect(User.last.email).to eq(user_email)
        expect(User.last.provider).to eq('google')
      end
    end

    context "when authentication fails" do
      before do
        mock_failed_oauth(provider: :google_oauth2)
      end

      after do
        reset_omniauth
      end

      it "redirects to the sign-in page with an error message" do
        get user_google_oauth2_omniauth_callback_path
        follow_redirect!

        expect(response.body).to include("Could not authenticate you")
      end
    end
  end
end
