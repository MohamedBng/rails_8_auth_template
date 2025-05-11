# frozen_string_literal: true

class UserAvatarComponent < ViewComponent::Base
  def initialize(user:, size:)
    @user = user
    @size = size
  end

  def avatar_status_class
    @user.online? ? "avatar-online" : "avatar-offline"
  end

  erb_template <<-ERB
    <div class="avatar <%= avatar_status_class %>">
      <div class="rounded-full flex items-center justify-center overflow-hidden" style="width: <%= @size %>px; height: <%= @size %>px;">
        <% if @user.profile_image.present? %>
          <%= image_tag @user.profile_image_url(:thumbnail), alt: @user.decorate.full_name, class: "w-full h-full object-cover" %>
        <% else %>
          <%= image_tag("avatar.png", alt: @user.decorate.full_name, class: "w-full h-full object-cover") %>
        <% end %>
      </div>
    </div>
  ERB
end
