module Users
  class GoogleOmniauthService
    extend Dry::Monads[:result]

    def self.call(auth:)
      user = User.find_or_initialize_by(email: auth[:email]) do |u|
        u.uid        = auth[:uid]
        u.first_name = auth[:first_name]
        u.last_name  = auth[:last_name]
        u.provider   = 'google'
        u.password   = Devise.friendly_token[0, 20]
      end

      user.set_default_role
      user.skip_confirmation!

      if user.save
        Success(user)
      else
        Failure(user.errors)
      end
    end
  end
end
