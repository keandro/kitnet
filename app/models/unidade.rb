# Uma das kitnets (fixas; criadas pelo seed). Guarda o valor base do aluguel,
# que sugere o valor de cada pagamento, e um status mudado à mão.
# "Descontinuada" é para unidades que não são mais alugadas (a antiga casa),
# mas que guardam pagamentos do passado.
class Unidade < ApplicationRecord
  include ValorMonetario
  valor_monetario :valor_base

  enum :status, { livre: 0, ocupada: 1, manutencao: 2, descontinuada: 3 }

  scope :em_uso, -> { where.not(status: :descontinuada) }

  # Unidades que aparecem nas telas de um mês: as em uso e as descontinuadas
  # até o mês do último pagamento delas.
  scope :do_mes, ->(data) {
    em_uso.or(where(id: Pagamento.where(data_pagamento: data.beginning_of_month..).select(:unidade_id)))
  }

  has_many :pagamentos, dependent: :restrict_with_error
  has_many :leituras_energia, class_name: "LeituraEnergia", dependent: :restrict_with_error

  # Valor base zerado é o mesmo que não ter valor base.
  before_validation { self.valor_base = nil if valor_base&.zero? }

  validates :nome, presence: true
  validates :valor_base, numericality: { greater_than: 0 }, allow_nil: true
end
