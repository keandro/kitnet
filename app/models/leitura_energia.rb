# Leitura do medidor de uma kitnet num mês. Consumo = leitura atual −
# leitura anterior; valor = consumo × valor do kWh da conta do mês.
class LeituraEnergia < ApplicationRecord
  self.table_name = "leituras_energia"

  belongs_to :conta_energia
  belongs_to :unidade

  validates :unidade_id, uniqueness: { scope: :conta_energia_id }
  validates :leitura_anterior, :leitura_atual, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :leitura_atual_nao_menor_que_anterior
  validate :data_pagamento_nao_pode_ser_futura

  def consumo
    leitura_atual - leitura_anterior if leitura_atual && leitura_anterior
  end

  def valor
    preco = conta_energia.valor_kwh
    (consumo * preco).round(2) if consumo && preco
  end

  def pago?
    data_pagamento.present?
  end

  private

  def leitura_atual_nao_menor_que_anterior
    errors.add(:leitura_atual, "não pode ser menor que a anterior") if consumo&.negative?
  end

  def data_pagamento_nao_pode_ser_futura
    errors.add(:data_pagamento, "não pode ser no futuro") if data_pagamento && data_pagamento > Date.current
  end
end
