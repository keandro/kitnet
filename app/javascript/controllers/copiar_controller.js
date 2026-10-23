import { Controller } from "@hotwired/stimulus"

// Botão "copiar" (chave Pix, conta). Pela rede de casa (http) o navegador não
// libera navigator.clipboard, então copia por um campo escondido.
export default class extends Controller {
  static values = { texto: String }

  async copiar() {
    try {
      await navigator.clipboard.writeText(this.textoValue)
    } catch {
      const campo = document.createElement("textarea")
      campo.value = this.textoValue
      campo.setAttribute("readonly", "")
      campo.style.cssText = "position:fixed;opacity:0"
      document.body.append(campo)
      campo.select()
      document.execCommand("copy")
      campo.remove()
    }
    this.element.classList.add("copiado")
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.element.classList.remove("copiado"), 1500)
  }
}
