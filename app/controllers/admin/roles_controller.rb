class Admin::RolesController < Admin::BaseController
  load_and_authorize_resource

  def index
    @roles = Role.with_users_count
  end
end
