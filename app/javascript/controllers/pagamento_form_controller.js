import { Controller } from "@hotwired/stimulus"

// Novo pagamento: ao escolher a kitnet, sugere o valor base dela.
// Não sobrescreve um valor digitado à mão.
export default class extends Controller {
  static targets = ["unidade", "valor"]

  connect() {
    this.sugerido = this.valorTarget.value
  }

  preencherValor() {
    const valorBase = this.unidadeTarget.selectedOptions[0]?.dataset.valorBase
    const atual = this.valorTarget.value

    if (atual && atual !== this.sugerido) return

    this.valorTarget.value = valorBase ?? ""
    this.sugerido = this.valorTarget.value
  }
}
