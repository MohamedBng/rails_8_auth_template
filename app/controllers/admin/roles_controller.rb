class Admin::RolesController < Admin::BaseController
  load_and_authorize_resource

  def index
    @roles = Role.with_users_count
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(role_params)

    if @role.save
      flash[:success] = t("admin.roles.create.success")
      redirect_to admin_roles_path
    else
      flash.now[:error] = @role.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @role = Role.find(params[:id]).with_users_count
  end

  private

  def role_params
    params.require(:role).permit(:name, :color)
  end
end
