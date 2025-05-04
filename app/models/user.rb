class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :omniauthable, omniauth_providers: [ :google_oauth2 ]

  validates :first_name, presence: true

  after_create :set_default_role, if: :new_record?

  has_many :users_roles, dependent: :destroy
  has_many :roles, through: :users_roles

  def self.from_google(u)
    user = find_or_initialize_by(email: u[:email]) do |new_user|
      new_user.uid         = u[:uid]
      new_user.first_name  = u[:first_name]
      new_user.last_name   = u[:last_name]
      new_user.provider    = "google"
      new_user.password    = Devise.friendly_token[0, 20]
    end

    user.set_default_role
    user.skip_confirmation!
    user.save!
    user
  end

  def has_permission?(permission_name)
    roles
      .joins(:permissions)
      .where(permissions: { name: permission_name })
      .exists?
  end

  def online?
    updated_at > 2.minutes.ago
  end

  def set_default_role
    self.roles << Role.find_or_create_by(name: "user") if roles.empty?
  end
end
