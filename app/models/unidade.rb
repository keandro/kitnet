# Uma das kitnets (fixas; criadas pelo seed). Guarda o valor base do aluguel,
# que sugere o valor de cada pagamento, e um status mudado à mão.
class Unidade < ApplicationRecord
  include ValorMonetario
  valor_monetario :valor_base

  enum :status, { livre: 0, ocupada: 1, manutencao: 2 }

  has_many :pagamentos, dependent: :restrict_with_error
  has_many :leituras_energia, class_name: "LeituraEnergia", dependent: :restrict_with_error

  validates :nome, presence: true
  validates :valor_base, numericality: { greater_than: 0 }, allow_nil: true
end
