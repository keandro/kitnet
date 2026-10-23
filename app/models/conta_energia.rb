# Conta de energia do mês: kWh total e valor total (sem o desconto da energia
# solar). O valor do kWh é calculado — valor total ÷ kWh — e guardado com 6
# casas para o rateio entre as kitnets; o valor realmente pago fica em
# EnergiaSolarMensal.
class ContaEnergia < ApplicationRecord
  self.table_name = "contas_energia"

  include ValorMonetario
  valor_monetario :valor_total

  has_many :leituras, class_name: "LeituraEnergia", dependent: :destroy

  validates :ano, numericality: { only_integer: true, in: 2000..2100 }
  validates :mes, numericality: { only_integer: true, in: 1..12 }, uniqueness: { scope: :ano }
  validates :kwh_total, :valor_total, numericality: { greater_than: 0 }, allow_nil: true

  before_save :calcular_valor_kwh, if: -> { will_save_change_to_kwh_total? || will_save_change_to_valor_total? }

  def self.do_mes(ano, mes)
    find_or_initialize_by(ano: ano, mes: mes)
  end


  private

  def calcular_valor_kwh
    self.valor_kwh = (valor_total / kwh_total).round(6) if valor_total && kwh_total.to_d.positive?
  end

  public

  def mes_anterior
    data = Date.new(ano, mes).prev_month
    ContaEnergia.find_by(ano: data.year, mes: data.month)
  end
end
