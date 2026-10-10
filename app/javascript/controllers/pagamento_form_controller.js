import { Controller } from "@hotwired/stimulus"

// Ao escolher o contrato de um novo pagamento, preenche o valor do aluguel e
// o próximo vencimento ainda sem pagamento lançado.
export default class extends Controller {
  static targets = ["contrato", "valor", "vencimento"]

  preencher() {
    const option = this.contratoTarget.selectedOptions[0]
    if (!option?.value) return

    this.valorTarget.value = option.dataset.valor ?? ""
    this.vencimentoTarget.value = option.dataset.vencimento ?? ""
  }
}
