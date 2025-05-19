# frozen_string_literal: true

class PaginationComponent < ViewComponent::Base
  attr_reader :pagy

  def initialize(pagy:)
    @pagy = pagy
  end

  erb_template <<-ERB
    <% if pagy.total_pages > 1 %>
      <div class="flex justify-center mt-4">
        <div class="join">
          <% (1..pagy.total_pages).each do |page| %>
            <% if page == pagy.current_page %>
              <span class="join-item btn btn-active"><%= page %></span>
            <% else %>
              <%= link_to page, url_for(params.permit!.to_h.merge(page: page)), class: "join-item btn" %>
            <% end %>
          <% end %>
        </div>
      </div>
    <% end %>
  ERB
end
