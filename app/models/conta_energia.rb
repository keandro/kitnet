# Conta de energia do mês (o total que chega na conta). O valor do kWh é
# derivado: valor total ÷ kWh total.
class ContaEnergia < ApplicationRecord
  self.table_name = "contas_energia"

  include ValorMonetario
  valor_monetario :valor_total

  has_many :leituras, class_name: "LeituraEnergia", dependent: :destroy

  validates :ano, numericality: { only_integer: true, in: 2000..2100 }
  validates :mes, numericality: { only_integer: true, in: 1..12 }, uniqueness: { scope: :ano }
  validates :kwh_total, :valor_total, numericality: { greater_than: 0 }, allow_nil: true

  def self.do_mes(ano, mes)
    find_or_initialize_by(ano: ano, mes: mes)
  end

  def valor_kwh
    valor_total / kwh_total if valor_total.to_d.positive? && kwh_total.to_d.positive?
  end

  def mes_anterior
    data = Date.new(ano, mes).prev_month
    ContaEnergia.find_by(ano: data.year, mes: data.month)
  end
end
