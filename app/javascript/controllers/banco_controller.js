import { Controller } from "@hotwired/stimulus"

// Ao digitar o código do banco, completa o nome (se ele estiver vazio ou tiver
// sido completado antes).
export default class extends Controller {
  static targets = ["codigo", "nome"]
  static values = { bancos: Object }

  completar() {
    const codigo = this.codigoTarget.value.replace(/\D/g, "").padStart(3, "0")
    const nome = this.bancosValue[codigo]
    const automatico = this.nomeTarget.value === "" || Object.values(this.bancosValue).includes(this.nomeTarget.value)
    if (nome && automatico) this.nomeTarget.value = nome
  }
}
