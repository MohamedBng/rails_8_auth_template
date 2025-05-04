class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :destroy, :edit, :update ]
  load_and_authorize_resource class: "User"

  def show
    @user = User.find(params[:id])
  end

  def edit
    render turbo_stream: turbo_stream.replace(
      "personal_info_user_#{@user.id}",
      partial: "admin/users/personal_info/form",
      locals: { user: @user }
    )
  end

  def update
    if @user.update(user_params)
      flash.now[:success] = t("admin.users.update.success")
      redirect_to admin_user_path(@user)
    else
      flash.now[:error] = t("admin.users.update.failure", errors: @user.errors.full_messages.join(", "))
      render turbo_stream: turbo_stream.replace(
        "personal_info_user_#{@user.id}",
        partial: "admin/users/personal_info/form",
        locals: { user: @user }
      ), status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy

    if @user.errors.any?
      flash[:error] = t("admin.users.destroy.failure", errors: @user.errors.full_messages.join(", "))
      redirect_to admin_user_path(@user)
      return
    end

    flash[:success] = t("admin.users.destroy.success")

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("main", template: "admin/dashboard/index") }
      format.html { redirect_to admin_dashboard_index_path }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name)
  end
end
