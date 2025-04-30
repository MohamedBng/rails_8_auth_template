class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :omniauthable, omniauth_providers: [ :google_oauth2 ]
  validates :first_name, presence: true

  def self.from_google(u)
    user = find_or_initialize_by(email: u[:email]) do |new_user|
      new_user.uid         = u[:uid]
      new_user.first_name  = u[:first_name]
      new_user.last_name   = u[:last_name]
      new_user.provider    = "google"
      new_user.password    = Devise.friendly_token[0, 20]
    end

    user.skip_confirmation!
    user.save!
    user
  end


  def full_name
    "#{first_name} #{last_name}"
  end
end
