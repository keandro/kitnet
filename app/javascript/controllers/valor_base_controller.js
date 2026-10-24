import { Controller } from "@hotwired/stimulus"

// Novo pagamento ou contrato: ao escolher a kitnet, sugere o valor base dela e,
// no pagamento, a data pelo dia do pagamento da kitnet (no mês de referência,
// nunca depois de hoje). Não sobrescreve o que foi digitado à mão.
export default class extends Controller {
  static targets = ["unidade", "valor", "data"]
  static values = { referencia: String, hoje: String }

  connect() {
    this.sugerido = this.valorTarget.value
    if (this.hasDataTarget) this.dataSugerida = this.dataTarget.value
  }

  preencherValor() {
    const valorBase = this.unidadeTarget.selectedOptions[0]?.dataset.valorBase
    const atual = this.valorTarget.value

    if (atual && atual !== this.sugerido) return

    this.valorTarget.value = valorBase ?? ""
    this.sugerido = this.valorTarget.value
  }

  preencherData() {
    if (!this.hasDataTarget || this.dataTarget.value !== this.dataSugerida) return

    const dia = Number(this.unidadeTarget.selectedOptions[0]?.dataset.diaPagamento)
    let data = this.referenciaValue
    if (dia) {
      const [ano, mes] = this.referenciaValue.split("-").map(Number)
      const ultimoDia = new Date(ano, mes, 0).getDate()
      data = `${ano}-${String(mes).padStart(2, "0")}-${String(Math.min(dia, ultimoDia)).padStart(2, "0")}`
    }
    if (data > this.hojeValue) data = this.hojeValue

    this.dataTarget.value = data
    this.dataSugerida = data
  }
}
