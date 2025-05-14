class Permission < ApplicationRecord
  has_many :roles_permissions, dependent: :destroy
  has_many :roles, through: :roles_permissions

  validates :name, presence: true, uniqueness: true

  scope :without_role, ->(role) {
    where.not(id: role.permissions.select(:id))
  }

  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[roles]
  end
end
