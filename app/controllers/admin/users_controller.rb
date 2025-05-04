class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :destroy, :edit, :update ]
  load_and_authorize_resource class: "User"

  def index
    @q = User.ransack(params[:q])
    @users = @q.result(distinct: true).includes(:roles).page(params[:page]).per(10)
  end

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

    redirect_to admin_users_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name)
  end
end
