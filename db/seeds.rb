# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create roles with color
roles_with_colors = {
  "admin" => "primary",
  "user"  => "info"
}

roles_with_colors.each do |role_name, color|
  role = Role.find_or_create_by!(name: role_name)
  role.update!(color: color)
end

# Assign permissions
perms = {
  "admin" => %w[destroy_user read_user read_dashboard update_any_user delete_profile_image],
  "user"  => %w[read_user read_dashboard update_own_user delete_own_profile_image]
}

perms.each do |role_name, keys|
  role = Role.find_by!(name: role_name)
  keys.each do |key|
    permission = Permission.find_or_create_by!(name: key)
    RolesPermission.find_or_create_by!(role: role, permission: permission)
  end
end
