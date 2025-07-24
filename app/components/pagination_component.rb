class PaginationComponent < ViewComponent::Base
  attr_reader :collection

  def initialize(collection:)
    @collection = collection
  end

  erb_template <<-ERB
    <% if collection.total_pages > 1 %>
      <div class="flex justify-center mt-4">
        <div class="join">
          <% (1..collection.total_pages).each do |page| %>
            <% if page == collection.current_page %>
              <span class="join-item btn btn-active"><%= page %></span>
            <% else %>
              <%= link_to page, url_for(params.permit!.to_h.merge(page: page, per_page: params[:per_page])), class: "join-item btn" %>
            <% end %>
          <% end %>
        </div>
      </div>
    <% end %>
  ERB
end
