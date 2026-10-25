# Conta de energia do mês. Lança-se só o valor do kWh (3 casas); a energia
# total e o valor total são a soma das kitnets (consumo e valor de cada
# leitura) e são refeitos quando o valor do kWh ou as leituras mudam. O valor
# realmente pago fica em EnergiaSolarMensal.
class ContaEnergia < ApplicationRecord
  self.table_name = "contas_energia"

  include ValorMonetario
  valor_monetario :valor_kwh

  has_many :leituras, class_name: "LeituraEnergia", dependent: :destroy

  validates :ano, numericality: { only_integer: true, in: 2000..2100 }
  validates :mes, numericality: { only_integer: true, in: 1..12 }, uniqueness: { scope: :ano }
  validates :valor_kwh, numericality: { greater_than: 0 }, allow_nil: true

  after_save :recalcular_totais!, if: :saved_change_to_valor_kwh?

  def self.do_mes(ano, mes)
    find_or_initialize_by(ano: ano, mes: mes)
  end

  def recalcular_totais!
    medidas = leituras.reload.select(&:consumo)
    kwh = medidas.sum(&:consumo) if medidas.any?
    valor = medidas.sum { |leitura| (leitura.consumo * valor_kwh).round(2) } if medidas.any? && valor_kwh
    update_columns(kwh_total: kwh, valor_total: valor)
  end

  def mes_anterior
    data = Date.new(ano, mes).prev_month
    ContaEnergia.find_by(ano: data.year, mes: data.month)
  end
end
