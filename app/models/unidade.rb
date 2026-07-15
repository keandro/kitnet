class Unidade < ApplicationRecord
  enum :status, { livre: 0, ocupada: 1, manutencao: 2 }

  has_many :contratos, dependent: :restrict_with_error

  validates :nome, presence: true
  validates :valor_base, numericality: { greater_than: 0 }, allow_nil: true

  def contrato_ativo
    contratos.ativo.first
  end

  def morador_atual
    contrato_ativo&.morador
  end
end
