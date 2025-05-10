import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "submitButton"]

  connect() {
    this.fieldTargets.forEach(field =>
      field.addEventListener("input", () => this.updateSubmitState())
    )
    this.updateSubmitState()
  }

  updateSubmitState() {
    const allFilled = this.fieldTargets
      .every(f => f.value.trim() !== "")
    this.submitButtonTarget.disabled = !allFilled
  }
}
