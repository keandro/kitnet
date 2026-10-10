import { Controller } from "@hotwired/stimulus"

// Máscara de dinheiro: os dígitos digitados entram como centavos e o campo
// mostra o valor formatado (1.234,56).
export default class extends Controller {
  connect() {
    if (this.element.value) this.format()
  }

  format() {
    const digitos = this.element.value.replace(/\D/g, "").replace(/^0+(?=\d)/, "")
    if (!digitos) {
      this.element.value = ""
      return
    }

    const centavos = digitos.padStart(3, "0")
    const reais = centavos.slice(0, -2).replace(/\B(?=(\d{3})+(?!\d))/g, ".")
    this.element.value = `${reais},${centavos.slice(-2)}`
  }
}
