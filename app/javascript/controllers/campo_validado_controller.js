import { Controller } from "@hotwired/stimulus"

// Máscara e verificação em tempo real para CPF, telefone e e-mail.
// O servidor valida de novo (Pessoa); aqui é só para avisar enquanto digita.
const DDDS = new Set(("11 12 13 14 15 16 17 18 19 21 22 24 27 28 31 32 33 34 35 37 38 " +
  "41 42 43 44 45 46 47 48 49 51 53 54 55 61 62 63 64 65 66 67 68 69 " +
  "71 73 74 75 77 79 81 82 83 84 85 86 87 88 89 91 92 93 94 95 96 97 98 99").split(" "))

const TIPOS = {
  cpf: {
    mascara(valor) {
      const d = valor.replace(/\D/g, "").slice(0, 11)
      return d.replace(/^(\d{3})(\d)/, "$1.$2")
              .replace(/^(\d{3})\.(\d{3})(\d)/, "$1.$2.$3")
              .replace(/\.(\d{3})(\d{1,2})$/, ".$1-$2")
    },
    completo: (valor) => valor.replace(/\D/g, "").length === 11,
    valido(valor) {
      const d = valor.replace(/\D/g, "")
      if (d.length !== 11 || /^(\d)\1{10}$/.test(d)) return false
      const n = [...d].map(Number)
      return [9, 10].every((tamanho) => {
        const soma = n.slice(0, tamanho).reduce((s, x, i) => s + x * (tamanho + 1 - i), 0)
        return ((soma * 10) % 11) % 10 === n[tamanho]
      })
    },
    erro: "CPF inválido"
  },

  telefone: {
    mascara(valor) {
      const d = valor.replace(/\D/g, "").slice(0, 11)
      if (d.length <= 2) return d.replace(/^(\d+)/, "($1")
      if (d.length <= 6) return d.replace(/^(\d{2})(\d+)/, "($1) $2")
      if (d.length <= 10) return d.replace(/^(\d{2})(\d{4})(\d+)/, "($1) $2-$3")
      return d.replace(/^(\d{2})(\d{5})(\d{4})/, "($1) $2-$3")
    },
    completo: (valor) => valor.replace(/\D/g, "").length >= 10,
    valido(valor) {
      const d = valor.replace(/\D/g, "")
      if (!DDDS.has(d.slice(0, 2))) return false
      return /^\d{2}9\d{8}$/.test(d) || /^\d{2}[2-5]\d{7}$/.test(d)
    },
    erro: "Telefone inválido (DDD + número)"
  },

  email: {
    mascara: (valor) => valor.trim(),
    completo: () => false,
    valido: (valor) => /^[^@\s]+@[^@\s]+\.[a-z]{2,}$/i.test(valor),
    erro: "E-mail inválido"
  }
}

export default class extends Controller {
  static targets = ["input", "erro"]
  static values = { tipo: String }

  connect() {
    if (this.inputTarget.value) this.inputTarget.value = this.tipo.mascara(this.inputTarget.value)
  }

  // Enquanto digita: aplica a máscara e, quando o valor já está completo, verifica.
  digitar() {
    if (this.tipoValue !== "email") this.inputTarget.value = this.tipo.mascara(this.inputTarget.value)
    if (this.tipo.completo(this.inputTarget.value) || this.inputTarget.getAttribute("aria-invalid") === "true") this.verificar()
  }

  // Ao sair do campo: verifica o que foi digitado.
  verificar() {
    const valor = this.inputTarget.value
    const invalido = valor !== "" && !this.tipo.valido(valor)

    this.inputTarget.setAttribute("aria-invalid", invalido)
    this.erroTarget.textContent = invalido ? this.tipo.erro : ""
    this.erroTarget.hidden = !invalido
  }

  get tipo() {
    return TIPOS[this.tipoValue]
  }
}
