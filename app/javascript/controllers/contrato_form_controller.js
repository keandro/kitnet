import { Controller } from "@hotwired/stimulus"

// Novo contrato: ao escolher a kitnet, sugere o valor base dela como aluguel.
// Não sobrescreve um valor digitado à mão.
export default class extends Controller {
  static targets = ["unidade", "aluguel"]

  preencherAluguel() {
    const valorBase = this.unidadeTarget.selectedOptions[0]?.dataset.valorBase
    const atual = this.aluguelTarget.value

    if (atual && atual !== this.sugerido) return

    this.aluguelTarget.value = valorBase ?? ""
    this.sugerido = this.aluguelTarget.value
  }
}
