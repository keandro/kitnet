class FinancasController < ApplicationController
  # GET /financas?ano=2026
  def index
    hoje = Date.current
    @ano = params[:ano].to_i.between?(2000, 2100) ? params[:ano].to_i : hoje.year
    @anos = anos_disponiveis(hoje.year)
    @resumo = ResumoFinanceiro.new(@ano)
  end

  private

  def anos_disponiveis(ano_atual)
    anos = Pagamento.pluck(Arel.sql("DISTINCT strftime('%Y', data_pagamento)")).compact.map(&:to_i)
    anos += FechamentoMensal.distinct.pluck(:ano) + EnergiaSolarMensal.distinct.pluck(:ano)
    (anos + [ ano_atual ]).uniq.sort
  end
end
