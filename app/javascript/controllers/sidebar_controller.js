// app/javascript/controllers/sidebar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label"]
  static classes = ["expanded", "collapsed"]

  connect() {
    this.open = false
    this.boundToggle = this.toggle.bind(this)
    this.element.addEventListener('toggle', this.boundToggle)
  }

  disconnect() {
    this.element.removeEventListener('toggle', this.boundToggle)
  }

  toggle() {
    this.open = !this.open
    this.update()
  }

  update() {
    if (this.open) {
      this.element.classList.remove(this.collapsedClass)
      this.element.classList.add(this.expandedClass)
      this.labelTargets.forEach(label => label.classList.remove('hidden'))
    } else {
      this.element.classList.remove(this.expandedClass)
      this.element.classList.add(this.collapsedClass)
      this.labelTargets.forEach(label => label.classList.add('hidden'))
    }
  }
}
