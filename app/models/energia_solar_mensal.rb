# Apuração mensal da energia solar.
#
#   valor sem solar = conta das kitnets (kWh total × tarifa, da página Energia)
#                     + energia do apartamento
#   pago            = conta paga do apartamento + conta paga das kitnets
#   lucro           = valor sem solar − pago
#
# O lucro entra na coluna "Energia solar" da página Finanças.
class EnergiaSolarMensal < ApplicationRecord
  self.table_name = "energia_solar_mensal"

  include ValorMonetario
  valor_monetario :valor_apartamento, :pago_apartamento, :pago_kitnets

  validates :ano, numericality: { only_integer: true, in: 2000..2100 }
  validates :mes, numericality: { only_integer: true, in: 1..12 }, uniqueness: { scope: :ano }
  validates :valor_apartamento, :pago_apartamento, :pago_kitnets, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def self.do_mes(ano, mes)
    find_or_initialize_by(ano: ano, mes: mes)
  end

  # Lucro de cada mês do ano, { mes => valor }, só dos meses apurados.
  def self.lucros_do_ano(ano)
    contas = ContaEnergia.where(ano: ano).index_by(&:mes)
    where(ano: ano).each_with_object({}) do |apuracao, lucros|
      apuracao.conta_energia = contas[apuracao.mes]
      lucros[apuracao.mes] = apuracao.lucro if apuracao.lucro
    end
  end

  attr_writer :conta_energia

  def conta_energia
    return @conta_energia if defined?(@conta_energia)

    @conta_energia = ContaEnergia.find_by(ano: ano, mes: mes)
  end

  def valor_kitnets
    conta_energia&.valor_total
  end

  def valor_sem_solar
    valor_kitnets.to_d + valor_apartamento.to_d if valor_kitnets || valor_apartamento
  end

  def total_pago
    pago_apartamento.to_d + pago_kitnets.to_d if pago_apartamento || pago_kitnets
  end

  def lucro
    valor_sem_solar - total_pago if valor_sem_solar && total_pago
  end
end
