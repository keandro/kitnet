class Pessoa < ApplicationRecord
  has_many :contratos_como_morador, class_name: "Contrato", foreign_key: :morador_id, dependent: :restrict_with_error
  has_many :contrato_fiadors, dependent: :destroy
  has_many :contratos_como_fiador, through: :contrato_fiadors, source: :contrato

  before_validation { self.cpf = cpf.gsub(/\D/, "") if cpf.present? }

  validates :nome, presence: true
  validates :cpf, presence: true, uniqueness: true, format: { with: /\A\d{11}\z/, message: "deve conter 11 dígitos" }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
