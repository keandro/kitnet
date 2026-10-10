import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Torna uma linha de tabela inteira clicável, levando para `url`.
// Cliques em links, botões e formulários da própria linha seguem normais.
export default class extends Controller {
  static values = { url: String }

  visit(event) {
    if (event.target.closest("a, button, form, input, select, textarea")) return
    if (window.getSelection().toString()) return

    if (event.ctrlKey || event.metaKey || event.button === 1) {
      window.open(this.urlValue, "_blank")
    } else {
      Turbo.visit(this.urlValue)
    }
  }
}
