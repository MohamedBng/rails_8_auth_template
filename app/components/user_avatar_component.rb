# frozen_string_literal: true

class UserAvatarComponent < ViewComponent::Base
  def initialize(user:, size:)
    @user = user
    @size = size
  end

  def avatar_status_class
    @user.online? ? "avatar-online" : "avatar-offline"
  end

  def full_name
    [ @user.first_name, @user.last_name ].join(" ")
  end

  erb_template <<-ERB
    <div class="avatar <%= avatar_status_class %>">
      <div class="rounded-full flex items-center justify-center" style="width: <%= @size %>px; height: <%= @size %>px;">
        <%= image_tag("avatar.png", alt: full_name) %>
      </div>
    </div>
  ERB
end
