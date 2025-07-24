import { Controller } from "@hotwired/stimulus"

// data-controller="select-all"
export default class extends Controller {
  static targets = ["checkbox", "master"]

  connect() {
    this.updateMasterState()
  }

  toggleAll(event) {
    const checked = event.target.checked
    this.checkboxTargets.forEach(cb => cb.checked = checked)
  }

  toggleOne() {
    this.updateMasterState()
  }

  updateMasterState() {
    if (!this.hasMasterTarget) return
    const allChecked = this.checkboxTargets.length > 0 &&
                       this.checkboxTargets.every(cb => cb.checked)
    this.masterTarget.checked = allChecked
  }
}
