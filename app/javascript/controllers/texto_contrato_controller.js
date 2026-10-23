import { Controller } from "@hotwired/stimulus"

// Editor do texto do contrato: clicar num campo escreve "{campo}" onde está o cursor.
export default class extends Controller {
  static targets = ["texto"]

  inserir(event) {
    const campo = `{${event.params.campo}}`
    const area = this.textoTarget
    const inicio = area.selectionStart ?? area.value.length
    area.setRangeText(campo, inicio, area.selectionEnd ?? inicio, "end")
    area.focus()
  }
}
