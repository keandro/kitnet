import { Controller } from "@hotwired/stimulus"

// Máscara de celular: (27) 99999-9999 enquanto digita.
export default class extends Controller {
  connect() {
    this.formatar()
  }

  formatar() {
    const d = this.element.value.replace(/\D/g, "").replace(/^55(?=\d{11})/, "").slice(0, 11)
    let v = d
    if (d.length > 2) v = `(${d.slice(0, 2)}) ${d.slice(2)}`
    if (d.length > 7) v = `(${d.slice(0, 2)}) ${d.slice(2, 7)}-${d.slice(7)}`
    this.element.value = v
  }
}
