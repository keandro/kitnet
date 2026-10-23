import { Controller } from "@hotwired/stimulus"

// Aviso flutuante (salvo, removido, erro): some sozinho depois de alguns segundos.
export default class extends Controller {
  static values = { duracao: { type: Number, default: 4500 } }

  connect() {
    this.timer = setTimeout(() => this.fechar(), this.duracaoValue)
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  fechar() {
    this.element.classList.add("opacity-0", "-translate-y-2")
    setTimeout(() => this.element.remove(), 300)
  }
}
