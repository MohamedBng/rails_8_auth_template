class Role < ApplicationRecord
  has_many :users_roles, dependent: :destroy_async
  has_many :users, through: :users_roles
  has_many :roles_permissions, dependent: :destroy_async
  has_many :permissions, through: :roles_permissions

  validates :name, presence: true, uniqueness: true
end
