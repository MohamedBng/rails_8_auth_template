require "rails_helper"

RSpec.describe "Google OAuth2 callback", type: :request do
  include OmniauthTestHelper

  let(:user_attrs) do
    {
      uid: "123456789",
      email: "user@example.com",
      first_name: "Jane",
      last_name: "Doe"
    }
  end
  let(:user_object) { build_stubbed(:user, user_attrs) }

  before do
    role = Role.find_or_create_by!(name: "user")
    role.permissions << Permission.find_or_create_by!(name: "read_dashboard")
  end

  after do
    reset_omniauth
  end

  context "when the user does not exist" do
    before do
      mock_successful_oauth(provider: :google_oauth2, user: user_object)
    end

    it "creates a new user" do
      expect {
        get user_google_oauth2_omniauth_callback_path
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(root_path)

      follow_redirect!

      expect(session["warden.user.user.key"]).not_to be_nil

      new_user = User.last
      expect(new_user.email).to eq(user_attrs[:email])
      expect(new_user.first_name).to eq(user_attrs[:first_name])
      expect(new_user.last_name).to eq(user_attrs[:last_name])
      expect(new_user.provider).to eq("google")
      expect(new_user.uid).to eq(user_attrs[:uid])
    end

    it "skips confirmation" do
      get user_google_oauth2_omniauth_callback_path

      new_user = User.last
      expect(new_user.confirmed_at).not_to be_nil
    end
  end

  context "when the user already exists" do
    let!(:existing_user) { create(:user, user_attrs.merge(provider: "google")) }

    before do
      mock_successful_oauth(provider: :google_oauth2, user: existing_user)
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

  context "when authentication fails (e.g. invalid credentials from provider)" do
    before do
      mock_failed_oauth(provider: :google_oauth2)
    end

    it "redirects to the sign-in page with an error message" do
      get user_google_oauth2_omniauth_callback_path
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to include("Could not authenticate you from Google")
    end
  end

  context "when OmniauthRouterService returns Failure(:unknown_provider)" do
    before do
      allow(Users::OmniauthRouterService).to receive(:call).and_return(Dry::Monads::Failure(:unknown_provider))
      mock_successful_oauth(provider: :google_oauth2, user: user_object)
    end

    it "redirects to the sign-in page with a generic error message" do
      get user_google_oauth2_omniauth_callback_path
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq(
        I18n.t("devise.omniauth_callbacks.failure", kind: "Google", reason: "#{user_attrs[:email]} is not authorized.")
      )
    end
  end
end
