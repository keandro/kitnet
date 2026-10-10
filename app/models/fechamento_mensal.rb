# Valores lançados à mão em cada mês da página Finanças: despesas gerais e
# água e esgoto (saem do resultado) e energia solar (entra no resultado;
# ainda não é editável, será calculada depois).
class FechamentoMensal < ApplicationRecord
  self.table_name = "fechamentos_mensais"

  include ValorMonetario
  valor_monetario :despesas_gerais, :agua_esgoto

  validates :ano, numericality: { only_integer: true, in: 2000..2100 }
  validates :mes, numericality: { only_integer: true, in: 1..12 }, uniqueness: { scope: :ano }
  validates :despesas_gerais, :agua_esgoto, numericality: { greater_than_or_equal_to: 0 }

  def self.do_ano(ano)
    where(ano: ano).index_by(&:mes)
  end
end
