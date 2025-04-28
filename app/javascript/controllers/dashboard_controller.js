// app/javascript/controllers/dashboard_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    window.addEventListener('toggle-sidebar', this.toggleSidebar)
  }

  disconnect() {
    window.removeEventListener('toggle-sidebar', this.toggleSidebar)
  }

  toggleSidebar() {
    const sidebar = document.querySelector('[data-controller="sidebar"]')
    if (sidebar) {
      sidebar.dispatchEvent(new CustomEvent('toggle', { bubbles: true }))
    }
  }
}
