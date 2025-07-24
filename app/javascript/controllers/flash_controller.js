import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dismissButton"]

  connect() {
    setTimeout(() => this.dismiss(), 5000)
  }

  dismiss() {
    this.element.remove()
  }

  dismissButtonClick(event) {
    event.preventDefault()
    this.dismiss()
  }
}
