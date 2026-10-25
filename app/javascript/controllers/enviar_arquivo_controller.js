import { Controller } from "@hotwired/stimulus"

// Formulário de um arquivo só: envia assim que o arquivo é escolhido.
export default class extends Controller {
  enviar() {
    this.element.requestSubmit()
  }
}
