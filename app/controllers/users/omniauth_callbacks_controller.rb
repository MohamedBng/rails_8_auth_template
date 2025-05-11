class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    result = Users::OmniauthRouterService.call(provider: auth.provider, auth: from_google_params)

    if result.success?
      user = result.value!
      sign_out_all_scopes
      flash[:notice] = t "devise.omniauth_callbacks.success", kind: "Google"
      sign_in_and_redirect user, event: :authentication
    else
      flash[:alert] = t "devise.omniauth_callbacks.failure", kind: "Google", reason: "#{auth.info.email} is not authorized."
      redirect_to new_user_session_path
    end
  end

  private

  def from_google_params
    @from_google_params ||= {
      uid: auth.uid,
      email: auth.info.email,
      first_name: auth.info.first_name,
      last_name: auth.info.last_name
    }
  end

  def auth
    @auth ||= request.env["omniauth.auth"]
  end
end
