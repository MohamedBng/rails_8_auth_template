class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    user = FactoryBot.build_stubbed(:user)
    Devise::Mailer.reset_password_instructions(user, "fake-token", {})
  end
end
