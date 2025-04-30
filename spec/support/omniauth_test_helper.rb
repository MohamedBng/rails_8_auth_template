# spec/support/omniauth_test_helper.rb
module OmniauthTestHelper
  def mock_successful_oauth(provider:, user:)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[provider.to_sym] = OmniAuth::AuthHash.new(
      provider: provider.to_s,
      uid: '123456789',
      info: {
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name
      },
      credentials: {
        token: 'fake_token',
        refresh_token: 'fake_refresh_token',
        expires_at: Time.now + 1.week
      }
    )
  end

  def mock_failed_oauth(provider:)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[provider.to_sym] = :invalid_credentials
  end

  def reset_omniauth
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth.clear
  end
end
