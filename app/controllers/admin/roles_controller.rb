class Admin::RolesController < Admin::BaseController
  load_and_authorize_resource

  def index
    @roles = Role.with_users_count
  end

  def show
    @role = Role.with_users_count.with_permissions_count.includes(users_roles: :user, roles_permissions: :permission).find(params[:id])
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(role_params)

    if @role.save
      redirect_to admin_roles_path, notice: t("admin.roles.create.success")
    else
      flash.now[:error] = @role.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    render turbo_stream: turbo_stream.replace(
      "role_basic_info_#{@role.id}",
      partial: "admin/roles/basic_infos/form",
      locals: { role: @role }
    )
  end

  def update
    if @role.update(role_params)
      redirect_to admin_role_path(@role), notice: t("admin.roles.update.success")
    else
      flash.now[:error] = t("admin.users.update.failure", errors: @role.errors.full_messages.join(", "))

      render turbo_stream: turbo_stream.replace(
        "role_basic_info_#{@role.id}",
        partial: "admin/roles/basic_infos/form",
        locals: { role: @role }
      ), status: :unprocessable_entity
    end
  end

  private

  def role_params
    params.require(:role).permit(:name, :color)
  end
end
