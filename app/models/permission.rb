class Permission < ApplicationRecord
  has_many :roles_permissions, dependent: :destroy
  has_many :roles, through: :roles_permissions

  validates :name, presence: true, uniqueness: true
end
