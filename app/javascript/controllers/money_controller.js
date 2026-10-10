import { Controller } from "@hotwired/stimulus"

// Máscara de dinheiro: os dígitos digitados entram pela última casa decimal
// e o campo mostra o valor formatado (1.234,56; com decimais: 4, 0,8523).
export default class extends Controller {
  static values = { decimais: { type: Number, default: 2 } }

  connect() {
    if (this.element.value) this.format()
  }

  format() {
    const casas = this.decimaisValue
    const digitos = this.element.value.replace(/\D/g, "").replace(/^0+(?=\d)/, "")
    if (!digitos) {
      this.element.value = ""
      return
    }

    const numero = digitos.padStart(casas + 1, "0")
    const inteiro = numero.slice(0, -casas).replace(/\B(?=(\d{3})+(?!\d))/g, ".")
    this.element.value = `${inteiro},${numero.slice(-casas)}`
  }
}
