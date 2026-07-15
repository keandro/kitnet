class Pessoa < ApplicationRecord
  has_many :contratos_como_morador, class_name: "Contrato", foreign_key: :morador_id, dependent: :restrict_with_error
  has_many :contrato_fiadores, dependent: :destroy
  has_many :contratos_como_fiador, through: :contrato_fiadores, source: :contrato

  before_validation { self.cpf = cpf.gsub(/\D/, "") if cpf.present? }

  validates :nome, presence: true
  validates :cpf, presence: true, uniqueness: true, format: { with: /\A\d{11}\z/, message: "deve conter 11 dígitos" }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

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
end
