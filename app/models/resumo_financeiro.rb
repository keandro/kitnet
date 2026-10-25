# Números de um ano para Finanças e Início: por mês, o recebido, os custos, o
# lucro da energia solar das kitnets e o resultado; mais os totais do ano.
class ResumoFinanceiro
  attr_reader :ano, :meses, :totais, :total_recebido, :media_mensal, :meses_com_movimento, :lucros_solar, :lucros_solar_kitnets

  def initialize(ano)
    @ano = ano
    recebido = Pagamento.where(data_pagamento: Date.new(ano).all_year).group("strftime('%m', data_pagamento)").sum(:valor)
    fechamentos = FechamentoMensal.do_ano(ano)
    @lucros_solar_kitnets = EnergiaSolarMensal.lucros_do_ano(ano, tipo: :lucro_kitnets)
    @lucros_solar = EnergiaSolarMensal.lucros_do_ano(ano)

    @meses = (1..12).map do |mes|
      fechamento = fechamentos[mes]
      linha = {
        mes: mes,
        recebido: recebido[format("%02d", mes)].to_d,
        despesas_gerais: fechamento&.despesas_gerais.to_d,
        agua_esgoto: fechamento&.agua_esgoto.to_d,
        energia_solar: @lucros_solar_kitnets[mes]
      }
      linha[:resultado] = linha[:recebido] + linha[:energia_solar].to_d - linha[:despesas_gerais] - linha[:agua_esgoto]
      linha
    end

    @total_recebido = @meses.sum { |m| m[:recebido] }
    @totais = %i[despesas_gerais agua_esgoto resultado].index_with { |campo| @meses.sum { |m| m[campo] } }
    @totais[:energia_solar] = @meses.sum { |m| m[:energia_solar].to_d }
    # Média do resultado nos meses do ano que tiveram algum movimento.
    @meses_com_movimento = @meses.count { |m| m[:recebido].nonzero? || m[:despesas_gerais].nonzero? || m[:agua_esgoto].nonzero? || m[:energia_solar] }
    @media_mensal = @meses_com_movimento.zero? ? 0 : @totais[:resultado] / @meses_com_movimento
  end
end
