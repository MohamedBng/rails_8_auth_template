class Role < ApplicationRecord
  has_many :users_roles, dependent: :destroy
  has_many :users, through: :users_roles
  has_many :roles_permissions, dependent: :destroy
  has_many :permissions, through: :roles_permissions

  validates :name, presence: true, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end
end
