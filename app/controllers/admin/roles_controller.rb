class Admin::RolesController < Admin::BaseController
  load_and_authorize_resource

  def index
    @roles = Role.left_joins(:users)
             .select('roles.*, COUNT(users.id) AS users_count')
             .group('roles.id')
  end
end
