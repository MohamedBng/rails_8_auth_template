class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :destroy]
  load_and_authorize_resource class: 'User'

  def show
  end

  def destroy
    @user.destroy

    if @user.errors.any?
      flash[:error] = "Failed to delete user: #{@user.errors.full_messages.join(', ')}"
      redirect_to admin_user_path(@user)
      return
    end

    flash[:success] = "User deleted successfully."

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("main", template: "admin/dashboard/index") }
      format.html { redirect_to admin_dashboard_index_path }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
