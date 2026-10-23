import { Controller } from "@hotwired/stimulus"

// Conta de energia: mostra o valor do kWh (valor total ÷ kWh) enquanto digita.
export default class extends Controller {
  static targets = ["kwh", "total", "resultado"]

  calcular() {
    const kwh = parseFloat(this.kwhTarget.value.replace(",", "."))
    const total = parseFloat(this.totalTarget.value.replace(/\./g, "").replace(",", "."))
    this.resultadoTarget.textContent = kwh > 0 && total > 0
      ? (total / kwh).toLocaleString("pt-BR", { style: "currency", currency: "BRL", minimumFractionDigits: 4, maximumFractionDigits: 4 })
      : "—"
  }
}
