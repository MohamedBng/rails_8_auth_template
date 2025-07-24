class Admin::Roles::RolesPermissionsController < Admin::BaseController
  load_resource :role, class: "Role", id_param: :role_id
  authorize_resource :roles_permission, class: "RolesPermission"

  def new
    # Display modal with permissions list that can be added to the role

    result = PermissionsWithoutRoleQuery.call(
      role:   @role,
      params: params[:q],
      per_page: params[:per_page],
      page:   params[:page]
    )

    @permissions_available = result[:permissions]
    @q = result[:search]

    render turbo_stream: turbo_stream.replace(
      "permissions_list",
      partial: "admin/roles/roles_permissions/permissions_list",
      locals: { role: @role, permissions_available: @permissions_available, q: @q }
    )
  end

  def create
    @role.add_permissions!(role_params[:permission_ids])
    redirect_to admin_role_path(@role), notice: t("admin.roles.add_role_to_permissions.success", count: role_params[:permission_ids].size, role_name: @role.name)
  end

  def destroy
    @role_permission = RolesPermission.find(params[:id])

    if @role_permission.destroy
      redirect_to admin_role_path(@role), notice: t("admin.roles.remove_permission.success", role_name: @role.name)
    else
      redirect_to admin_role_path(@role), alert: @role_permission.errors.full_messages.to_sentence
    end
  end

  private

  def role_params
    params.require(:role_permission).permit(permission_ids: [])
  end
end
