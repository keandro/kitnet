# Quem aluga as kitnets (dono). Cada contrato escolhe o seu locador; os dados
# entram no contrato para assinar.
class Locador < ApplicationRecord
  has_many :contratos, dependent: :nullify

  normalizes :nome, :nacionalidade, :estado_civil, :profissao, :endereco, with: ->(texto) { texto.squish.presence }
  # CPF sempre no padrão 000.000.000-00 (com 11 dígitos; senão fica como veio e a validação avisa).
  normalizes :cpf, with: ->(cpf) {
    digitos = cpf.gsub(/\D/, "")
    digitos.length == 11 ? digitos.sub(/\A(\d{3})(\d{3})(\d{3})(\d{2})\z/, '\\1.\\2.\\3-\\4') : cpf.squish.presence
  }

  validates :nome, presence: true
  validate { errors.add(:cpf, "não é válido (use 000.000.000-00)") if cpf.present? && !Contrato.cpf_valido?(cpf) }

  scope :ordenados, -> { order(:nome) }

  # "brasileiro, solteiro, advogado", como vai no contrato.
  def qualificacao
    [ nacionalidade, estado_civil, profissao ].compact.join(", ").presence
  end
end
