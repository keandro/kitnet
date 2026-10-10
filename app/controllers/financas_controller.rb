class FinancasController < ApplicationController
  # GET /financas?ano=2026
  def index
    hoje = Date.current
    @ano = params[:ano].to_i.between?(2000, 2100) ? params[:ano].to_i : hoje.year
    @anos = anos_disponiveis(hoje.year)

    periodo = Date.new(@ano).all_year
    recebido = Pagamento.where(data_pagamento: periodo).group("strftime('%m', data_pagamento)").sum(:valor)
    previsto = Pagamento.where(data_vencimento: periodo).group("strftime('%m', data_vencimento)").sum(:valor)

    @meses = (1..12).map do |mes|
      chave = format("%02d", mes)
      { mes: mes, recebido: recebido[chave].to_d, previsto: previsto[chave].to_d }
    end
    @meses.each_cons(2) { |anterior, atual| atual[:anterior] = anterior[:recebido] }

    # Mês de referência: o atual no ano corrente, dezembro nos anos passados.
    @mes_referencia = @ano == hoje.year ? hoje.month : (@ano < hoje.year ? 12 : 1)
    @referencia = @meses[@mes_referencia - 1]
    @total_recebido = @meses.sum { |m| m[:recebido] }
    @total_previsto = @meses.sum { |m| m[:previsto] }
    @media_mensal = @total_recebido / @mes_referencia
    @em_aberto = Pagamento.where(data_pagamento: nil, data_vencimento: periodo.first..[ periodo.last, hoje ].min).sum(:valor)
  end

  private

  def anos_disponiveis(ano_atual)
    anos = Pagamento.pluck(Arel.sql("DISTINCT strftime('%Y', data_vencimento)")).compact.map(&:to_i)
    (anos + [ ano_atual ]).uniq.sort
  end
end
