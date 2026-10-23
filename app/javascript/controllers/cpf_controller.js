import { Controller } from "@hotwired/stimulus"

// Máscara de CPF: 000.000.000-00 enquanto digita.
export default class extends Controller {
  connect() {
    this.formatar()
  }

  formatar() {
    const d = this.element.value.replace(/\D/g, "").slice(0, 11)
    this.element.value = d.replace(/^(\d{3})(\d)/, "$1.$2").replace(/^(\d{3})\.(\d{3})(\d)/, "$1.$2.$3").replace(/\.(\d{3})(\d{1,2})$/, ".$1-$2")
  }
}
