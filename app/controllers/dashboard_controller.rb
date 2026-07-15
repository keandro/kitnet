class DashboardController < ApplicationController
  def index
    @total_pessoas = Pessoa.count
    @total_unidades = Unidade.count
    @unidades_por_status = Unidade.group(:status).count
    @contratos_ativos = Contrato.ativo.count
    @pagamentos_vencidos = Pagamento.vencidos
    @pagamentos_pendentes = Pagamento.pendentes
    @valor_vencido = @pagamentos_vencidos.sum(:valor)
    @proximos_pagamentos = (@pagamentos_vencidos + @pagamentos_pendentes)
      .sort_by(&:data_vencimento)
      .first(6)
  end
end
