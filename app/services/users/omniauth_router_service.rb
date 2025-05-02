module Users
  class OmniauthRouterService
    extend Dry::Monads[:result]

    PROVIDERS = {
      'google_oauth2' => GoogleOmniauthService
    }.freeze

    def self.call(provider:, auth:)
      service = PROVIDERS[provider.to_s]

      return Failure(:unknown_provider) unless service

      service.call(auth: auth)
    end
  end
end
