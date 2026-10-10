# Uma das kitnets (fixas; criadas pelo seed). Guarda o valor base do aluguel,
# que sugere o valor de cada pagamento, e um status mudado à mão.
# "Descontinuada" é para unidades que não são mais alugadas (a antiga casa),
# mas que guardam pagamentos do passado.
class Unidade < ApplicationRecord
  include ValorMonetario
  valor_monetario :valor_base

  enum :status, { livre: 0, ocupada: 1, manutencao: 2, descontinuada: 3 }

  scope :em_uso, -> { where.not(status: :descontinuada) }

  has_many :pagamentos, dependent: :restrict_with_error
  has_many :leituras_energia, class_name: "LeituraEnergia", dependent: :restrict_with_error

  validates :nome, presence: true
  validates :valor_base, numericality: { greater_than: 0 }, allow_nil: true
end
