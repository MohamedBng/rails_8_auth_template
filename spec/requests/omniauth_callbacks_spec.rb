require "rails_helper"
require "ostruct"

RSpec.describe "Google OAuth2 callback", type: :request do
  include OmniauthTestHelper

  let(:user_attrs) do
    {
      uid:         "123456789",
      email:       "user@example.com",
      first_name:  "Jane",
      last_name:   "Doe"
    }
  end

  after do
    reset_omniauth
  end

  context "when the user does not exist" do
    before do
      mock_successful_oauth(
        provider: :google_oauth2,
        user: OpenStruct.new(user_attrs)
      )
    end

    it "creates a new user" do
      expect {
        get user_google_oauth2_omniauth_callback_path
      }.to change(User, :count).by(1)

      follow_redirect!

      expect(session["warden.user.user.key"]).to be_nil

      new_user = User.last
      expect(new_user.email).to      eq(user_attrs[:email])
      expect(new_user.first_name).to eq(user_attrs[:first_name])
      expect(new_user.last_name).to  eq(user_attrs[:last_name])
      expect(new_user.confirmed_at).to be_nil
      expect(new_user.provider).to   eq("google")
      expect(new_user.uid).to        eq(user_attrs[:uid])
    end
  end

  context "when the user already exists" do
    let!(:user) { create(:user, user_attrs.merge(provider: "google")) }

    before do
      mock_successful_oauth(
        provider: :google_oauth2,
        user:     OpenStruct.new(user_attrs)
      )
    end

    it "does not create a duplicate user" do
      expect {
        get user_google_oauth2_omniauth_callback_path
      }.not_to change(User, :count)

      expect(response).to redirect_to(root_path)
      follow_redirect!

      expect(session["warden.user.user.key"]).not_to be_nil
    end
  end

  context "when authentication fails" do
    before do
      mock_failed_oauth(provider: :google_oauth2)
    end

    it "redirects to the sign-in page with an error message" do
      get user_google_oauth2_omniauth_callback_path
      follow_redirect!

      expect(response.body).to include("Could not authenticate you")
    end
  end
end
