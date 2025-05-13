class Role < ApplicationRecord
  has_many :users_roles, dependent: :destroy
  has_many :users, through: :users_roles
  has_many :roles_permissions, dependent: :destroy
  has_many :permissions, through: :roles_permissions

  validates :name, presence: true, uniqueness: true

  scope :with_users_count, -> {
    joins("LEFT JOIN users_roles ON users_roles.role_id = roles.id")
      .select("roles.*, COUNT(DISTINCT users_roles.user_id) AS users_count")
      .group("roles.id")
  }

  scope :with_permissions_count, -> {
    joins("LEFT JOIN roles_permissions ON roles_permissions.role_id = roles.id")
      .select("roles.*, COUNT(DISTINCT roles_permissions.permission_id) AS permissions_count")
      .group("roles.id")
  }

  def self.ransackable_attributes(auth_object = nil)
    [ "name" ]
  end

  def add_users!(user_ids)
    processed_user_ids = Array(user_ids).map(&:to_s).compact_blank.uniq
    return if processed_user_ids.empty?

    current_user_ids = self.user_ids.map(&:to_s)
    ids_to_add = processed_user_ids - current_user_ids

    return if ids_to_add.empty?

    self.users << User.where(id: ids_to_add)
  end
end
