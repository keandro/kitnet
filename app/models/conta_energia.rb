# Conta de energia do mês: kWh total e a tarifa cheia do kWh. O valor total
# é kWh × tarifa, ou seja, quanto a energia custaria sem a energia solar; o
# valor realmente pago fica em EnergiaSolarMensal.
class ContaEnergia < ApplicationRecord
  self.table_name = "contas_energia"

  include ValorMonetario
  valor_monetario :valor_kwh

  has_many :leituras, class_name: "LeituraEnergia", dependent: :destroy

  validates :ano, numericality: { only_integer: true, in: 2000..2100 }
  validates :mes, numericality: { only_integer: true, in: 1..12 }, uniqueness: { scope: :ano }
  validates :kwh_total, :valor_kwh, numericality: { greater_than: 0 }, allow_nil: true

  def self.do_mes(ano, mes)
    find_or_initialize_by(ano: ano, mes: mes)
  end

  def valor_total
    (kwh_total * valor_kwh).round(2) if kwh_total && valor_kwh
  end

  def mes_anterior
    data = Date.new(ano, mes).prev_month
    ContaEnergia.find_by(ano: data.year, mes: data.month)
  end
end
