// app/javascript/controllers/headbar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleSidebar() {
    const event = new CustomEvent('toggle-sidebar', { bubbles: true })
    window.dispatchEvent(event)
  }
}
