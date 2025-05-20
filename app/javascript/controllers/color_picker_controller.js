// app/javascript/controllers/color_picker_controller.js
import { Controller } from "@hotwired/stimulus"
import Pickr from '@simonwep/pickr'
import '@simonwep/pickr/dist/themes/nano.min.css'

export default class extends Controller {
  static targets = ["input", "container"]

  connect() {
    this.pickr = Pickr.create({
      el: this.containerTarget,
      theme: 'nano',
      default: this.inputTarget.value || '#000000',
      components: {
        preview: true,
        opacity: true,
        hue: true,
        interaction: {
          hex: true,
          rgba: true,
          input: true,
          clear: true,
          save: true
        }
      }
    })

    this.pickr.on('save', color => {
      if (!color) return
      const hex = color.toHEXA().toString()
      this.inputTarget.value = hex
      this.inputTarget.dispatchEvent(new Event('input'))
      this.pickr.hide()
    })
  }

  show() {
    this.pickr.show()
  }

  disconnect() {
    this.pickr && this.pickr.destroy()
  }
}
