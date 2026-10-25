# Custos lançados em cada mês (na página Pagamentos): despesas gerais e água e
# esgoto, que saem do resultado. Água e esgoto vem de dois relógios e
# agua_esgoto guarda a soma deles. A energia solar, que entra no
# resultado, vem de EnergiaSolarMensal.
class FechamentoMensal < ApplicationRecord
  self.table_name = "fechamentos_mensais"

  include ValorMonetario
  valor_monetario :despesas_gerais, :agua_esgoto, :agua_esgoto_1, :agua_esgoto_2

  # Campo de custo apagado no formulário vale R$ 0,00.
  before_validation do
    self.despesas_gerais ||= 0
    self.agua_esgoto_1 ||= 0
    self.agua_esgoto_2 ||= 0
    self.agua_esgoto = agua_esgoto_1 + agua_esgoto_2
  end

  validates :ano, numericality: { only_integer: true, in: 2000..2100 }
  validates :mes, numericality: { only_integer: true, in: 1..12 }, uniqueness: { scope: :ano }
  validates :despesas_gerais, :agua_esgoto_1, :agua_esgoto_2, numericality: { greater_than_or_equal_to: 0 }

  def self.do_ano(ano)
    where(ano: ano).index_by(&:mes)
  end
end
