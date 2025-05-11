require "rails_helper"
require "ostruct"

RSpec.describe "Google OAuth2 callback", type: :request do
  let(:user_attrs) do
    {
      uid:         "123456789",
      email:       "user@example.com",
      first_name:  "Jane",
      last_name:   "Doe"
    }
  end

  before do
    OmniAuth.config.test_mode = true
    role = Role.find_or_create_by!(name: "user")
    role.permissions << Permission.find_or_create_by!(name: "read_dashboard")
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth.clear
  end

  context "when the user does not exist" do
    before do
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: user_attrs[:uid],
        info: {
          email: user_attrs[:email],
          first_name: user_attrs[:first_name],
          last_name: user_attrs[:last_name]
        },
        credentials: {
          token: 'fake_token',
          refresh_token: 'fake_refresh_token',
          expires_at: Time.now + 1.week
        }
      )
    end

    it "creates a new user" do
      expect {
        get user_google_oauth2_omniauth_callback_path
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(root_path)

      follow_redirect!

      expect(session["warden.user.user.key"]).not_to be_nil

      new_user = User.last
      expect(new_user.email).to      eq(user_attrs[:email])
      expect(new_user.first_name).to eq(user_attrs[:first_name])
      expect(new_user.last_name).to  eq(user_attrs[:last_name])
      expect(new_user.provider).to   eq("google")
      expect(new_user.uid).to        eq(user_attrs[:uid])
    end

    it "skips confirmation" do
      get user_google_oauth2_omniauth_callback_path

      new_user = User.last
      expect(new_user.confirmed_at).not_to be_nil
    end
  end

  context "when the user already exists" do
    let!(:user) { create(:user, user_attrs.merge(provider: "google")) }

    before do
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: user_attrs[:uid],
        info: {
          email: user_attrs[:email],
          first_name: user_attrs[:first_name],
          last_name: user_attrs[:last_name]
        },
        credentials: {
          token: 'fake_token',
          refresh_token: 'fake_refresh_token',
          expires_at: Time.now + 1.week
        }
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
      OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
    end

    it "redirects to the sign-in page with an error message" do
      get user_google_oauth2_omniauth_callback_path
      follow_redirect!

      expect(response.body).to include("Could not authenticate you")
    end
  end
end
