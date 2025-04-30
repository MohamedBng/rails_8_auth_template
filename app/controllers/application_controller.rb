class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  after_action :update_user_online, if: :user_signed_in?

  private

  def update_user_online
    current_user.try :touch
  end
end
