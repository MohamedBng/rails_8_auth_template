# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
%w[admin user].each do |role_name|
  Role.find_or_create_by!(name: role_name)
end

perms = {
  "admin"     => %w[destroy_user read_user read_dashboard],
  "user"      => %w[read_user read_dashboard],
}

perms.each do |role_name, keys|
  role = Role.find_by!(name: role_name)
  keys.each do |key|
    permission = Permission.find_or_create_by!(name: key)
    RolesPermission.find_or_create_by!(role: role, permission: permission)
  end
end

