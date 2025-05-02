class Admin::DashboardController < Admin::BaseController
  before_action :set_user, only: [ :index ]

  def index
    authorize! :read, :dashboard
  end

  private

  def set_user
    @user = current_user
  end
end
