class User < ApplicationRecord
  include ImageUploader::Attachment(:profile_image)

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :omniauthable, omniauth_providers: [ :google_oauth2 ]

  validates :first_name, presence: true

  after_create :set_default_role, if: :new_record?

  has_many :users_roles, dependent: :destroy
  has_many :roles, through: :users_roles

  scope :without_role, ->(role) {
    where.not(id: role.users.select(:id))
  }

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

  def self.ransackable_attributes(auth_object = nil)
    %w[first_name last_name email]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[roles]
  end
end
