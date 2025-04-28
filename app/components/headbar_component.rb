# frozen_string_literal: true

class HeadbarComponent < ViewComponent::Base
  erb_template <<-ERB
    <header class="navbar bg-base-100 shadow-sm sticky top-0 z-10" data-controller="headbar">
      <div class="flex-1 flex items-center">
        <button type="button" class="btn btn-ghost btn-sm" data-action="headbar#toggleSidebar">
          <i class="fas fa-bars text-2xl"></i>
        </button>
      </div>
      <div class="flex items-center gap-4">
        <div class="avatar">
          <div class="w-10 rounded-full">
            <img src="https://img.daisyui.com/images/stock/photo-1534528741775-53994a69daeb.webp" />
          </div>
        </div>
      </div>
    </header>
  ERB
end
