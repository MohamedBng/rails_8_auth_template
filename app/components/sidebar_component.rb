# frozen_string_literal: true

class SidebarComponent < ViewComponent::Base
  def initialize(current_user:)
    @current_user = current_user
  end

  erb_template <<-ERB
    <aside class="bg-base-100 flex flex-col transition-all duration-300 w-20" data-controller="sidebar" data-sidebar-expanded-class="w-64" data-sidebar-collapsed-class="w-20">
      <div class="flex-1 p-4 space-y-6">
        <%= link_to root_path, class: 'text-2xl font-bold flex items-center gap-2' do %>
          <%= image_tag 'logo.png', alt: 'Logo', class: 'h-10 w-10' %>
          <span data-sidebar-target="label" class="hidden">App name</span>
        <% end %>

        <nav class="space-y-4">
          <% if @current_user.has_permission?("read_dashboard") %>
            <%= link_to admin_dashboard_index_path, data: { turbo_frame: "main", turbo_action: "advance" }, class: 'flex items-center gap-4 hover:bg-base-200 p-2 rounded' do %>
              <i class="fas fa-chart-line"></i>
              <span data-sidebar-target="label" class="hidden"><%= t("sidebar.dashboard") %></span>
            <% end %>
          <% end %>

          <% if @current_user.has_permission?("read_user") %>
            <%= link_to admin_users_path, data: { turbo_frame: "main", turbo_action: "advance" }, class: 'flex items-center gap-4 hover:bg-base-200 p-2 rounded' do %>
              <i class="fas fa-users"></i>
              <span data-sidebar-target="label" class="hidden"><%= t("sidebar.users") %></span>
            <% end %>
          <% end %>

          <% if @current_user.has_permission?("read_role") %>
            <%= link_to admin_roles_path, data: { turbo_frame: "main", turbo_action: "advance" }, class: 'flex items-center gap-4 hover:bg-base-200 p-2 rounded' do %>
              <i class="fas fa-user-shield"></i>
              <span data-sidebar-target="label" class="hidden"><%= t("sidebar.roles") %></span>
            <% end %>
          <% end %>
        </nav>
      </div>

      <div class="p-4">
        <%= button_to destroy_user_session_path, method: :delete, class: 'btn btn-accent w-full flex items-center justify-center gap-2' do %>
          <i class="fas fa-sign-out-alt text-lg"></i>
          <span data-sidebar-target="label" class="hidden"><%= t("sidebar.logout") %></span>
        <% end %>
      </div>
    </aside>
  ERB
end
