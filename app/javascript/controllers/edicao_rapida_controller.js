import { Controller } from "@hotwired/stimulus"

// Edição rápida no próprio cartão: o lápis troca o valor exibido por um campo.
export default class extends Controller {
  static targets = ["exibicao", "formulario", "campo"]

  editar(event) {
    event.preventDefault()
    this.valorOriginal = this.campoTarget.value
    this.exibicaoTarget.hidden = true
    this.formularioTarget.classList.remove("hidden")
    this.campoTarget.focus()
    this.campoTarget.select()
  }

  cancelar() {
    if (this.formularioTarget.classList.contains("hidden")) return
    this.campoTarget.value = this.valorOriginal ?? this.campoTarget.value
    this.formularioTarget.classList.add("hidden")
    this.exibicaoTarget.hidden = false
  }
}
