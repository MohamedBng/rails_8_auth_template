class Admin::Roles::UserRolesController < Admin::BaseController
  load_resource :role, class: "Role", id_param: :role_id
  authorize_resource :user_role, class: "UsersRole"

  def new
    # Display modal with users list that can be added to the role

    result = UsersWithoutRoleQuery.call(
      role:   @role,
      params: params[:q],
      page:   params[:page]
    )

    @users_available = result[:users]
    @q = result[:search]

    render turbo_stream: turbo_stream.replace(
      "users_list",
      partial: "admin/roles/users_list",
      locals: { role: @role, users_available: @users_available, q: @q }
    )
  end

  def create
    @role.add_users!(role_params[:user_ids])
    redirect_to admin_role_path(@role), notice: t("admin.roles.add_role_to_users.success", count: role_params[:user_ids].size, role_name: @role.name)
  end

  def destroy
    @users_role = UsersRole.find(params[:id])

    if @users_role.destroy
      redirect_to admin_role_path(@role), notice: t("admin.user_roles.user_removed", role_name: @role.name)
    else
      redirect_to admin_role_path(@role), alert: @users_role.errors.full_messages.to_sentence
    end
  end

  private

  def role_params
    params.require(:role_user).permit(user_ids: [])
  end
end
