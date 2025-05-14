import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "field", "submitButton"]

  connect() {
    this.checkboxTargets.forEach(cb =>
      cb.addEventListener("change", () => this.updateSubmitState())
    )
    
    this.fieldTargets.forEach(f =>
      f.addEventListener("input",   () => this.updateSubmitState())
    )

    this.updateSubmitState()
  }

  updateSubmitState() {
    const checkboxOk = this.checkboxTargets.length === 0
      || this.checkboxTargets.some(cb => cb.checked)

    const fieldOk = this.fieldTargets.length === 0
      || this.fieldTargets.every(f => f.value.trim() !== "")

    this.submitButtonTarget.disabled = !(checkboxOk && fieldOk)
  }
}
