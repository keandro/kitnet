import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Janela de confirmação do próprio sistema, no lugar do confirm() do navegador,
// para tudo que usa data-turbo-confirm. O botão de confirmar usa o texto de
// data-confirmar-rotulo (no botão ou no formulário); ações de remover ficam vermelhas.
// A resposta vem do clique nos botões, do Esc ou do clique fora da caixa (o evento
// "close" é só reserva: nem toda WebView o dispara).
export default class extends Controller {
  static targets = ["mensagem", "confirmar", "icone"]

  connect() {
    Turbo.config.forms.confirm = (mensagem, formulario, botao) => this.perguntar(mensagem, formulario, botao)
  }

  perguntar(mensagem, formulario, botao) {
    this.responder(false) // se havia outra pergunta aberta, ela é cancelada

    const origem = botao?.dataset.confirmarRotulo ? botao : formulario
    const remover = formulario?.querySelector('input[name="_method"][value="delete"]') || origem?.dataset.confirmarPerigo === "true"

    this.mensagemTarget.textContent = mensagem
    this.confirmarTarget.textContent = origem?.dataset.confirmarRotulo || (remover ? "Remover" : "Confirmar")
    this.confirmarTarget.classList.toggle("btn-danger-solido", Boolean(remover))
    this.confirmarTarget.classList.toggle("btn-primary", !remover)
    this.iconeTarget.classList.toggle("perigo", Boolean(remover))

    this.element.showModal()
    this.confirmarTarget.focus()
    return new Promise((resolver) => { this.resolver = resolver })
  }

  confirmar() {
    this.responder(true)
  }

  cancelar(event) {
    event?.preventDefault()
    this.responder(false)
  }

  // Clicar fora da caixa (no fundo escurecido) cancela.
  fora(event) {
    if (event.target === this.element) this.responder(false)
  }

  responder(resposta) {
    if (this.element.open) this.element.close()
    const resolver = this.resolver
    this.resolver = null
    resolver?.(resposta)
  }
}
