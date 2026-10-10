class Pessoa < ApplicationRecord
  has_many :contratos_como_morador, class_name: "Contrato", foreign_key: :morador_id, dependent: :restrict_with_error
  has_many :contrato_fiadores, dependent: :destroy
  has_many :contratos_como_fiador, through: :contrato_fiadores, source: :contrato

  EMAIL_REGEXP = /\A[^@\s]+@[^@\s]+\.[a-z]{2,}\z/i

  before_validation :normalizar_contatos

  validates :nome, presence: true
  validates :cpf, presence: true, uniqueness: true
  validate :cpf_verdadeiro
  validate :telefone_verdadeiro
  validates :email, format: { with: EMAIL_REGEXP, message: "é inválido" }, allow_blank: true

  def cpf_formatado
    DocumentoBrasileiro.formatar_cpf(cpf)
  end

  def telefone_formatado
    DocumentoBrasileiro.formatar_telefone(telefone)
  end

  def morador_ativo?
    contratos_como_morador.ativo.exists?
  end

  def fiador_ativo?
    contratos_como_fiador.ativo.exists?
  end

  def categoria
    if morador_ativo? && fiador_ativo?
      :ambos
    elsif morador_ativo?
      :morador
    elsif fiador_ativo?
      :fiador
    else
      :sem_contrato_ativo
    end
  end

  private

  def normalizar_contatos
    self.cpf = cpf.gsub(/\D/, "") if cpf.present?
    self.telefone = telefone.gsub(/\D/, "").presence if telefone
    self.email = email.strip.downcase.presence if email
  end

  def cpf_verdadeiro
    errors.add(:cpf, "é inválido") if cpf.present? && !DocumentoBrasileiro.cpf_valido?(cpf)
  end

  def telefone_verdadeiro
    errors.add(:telefone, "é inválido (informe DDD + número)") if telefone.present? && !DocumentoBrasileiro.telefone_valido?(telefone)
  end
end
