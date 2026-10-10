import { Controller } from "@hotwired/stimulus"

// "Sem fiador" marcado: esconde e desabilita a seleção de fiadores.
export default class extends Controller {
  static targets = ["checkbox", "campo", "select"]

  connect() {
    this.toggle()
  }

  toggle() {
    const semFiador = this.checkboxTarget.checked
    this.campoTarget.hidden = semFiador
    this.selectTarget.disabled = semFiador
  }
}
