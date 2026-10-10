class DashboardController < ApplicationController
  def index
    @total_pessoas = Pessoa.count
    @total_unidades = Unidade.count
    @unidades_por_status = Unidade.group(:status).count
    @contratos_ativos = Contrato.ativo.count
    @pagamentos_vencidos = Pagamento.vencidos
    @pagamentos_pendentes = Pagamento.pendentes
    @valor_vencido = @pagamentos_vencidos.sum(:valor)
    # Em aberto: todos os vencidos e os que vencem até um mês a partir de hoje
    # (o que sempre cobre o restante do mês atual).
    @proximos_pagamentos = Pagamento.where(data_pagamento: nil)
      .where(data_vencimento: ..Date.current.next_month)
      .includes(contrato: [ :morador, :unidade ])
      .order(:data_vencimento)
  end
end
