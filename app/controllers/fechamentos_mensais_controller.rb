# Custos do mês (despesas gerais e os dois relógios de água e esgoto), lançados na página Pagamentos.
class FechamentosMensaisController < ApplicationController
  # PATCH /financas/2026/10
  def update
    fechamento = FechamentoMensal.find_or_initialize_by(ano: params[:ano].to_i, mes: params[:mes].to_i)
    raise ActionController::RoutingError, "Mês inválido" unless fechamento.ano.between?(2000, 2100) && fechamento.mes.between?(1, 12)

    nome_do_mes = "#{I18n.t("date.month_names")[fechamento.mes]} de #{fechamento.ano}"
    destino = pagamentos_path(ano: fechamento.ano, mes: fechamento.mes)
    if fechamento.update(params.expect(fechamento_mensal: [ :despesas_gerais, :agua_esgoto_1, :agua_esgoto_2 ]))
      redirect_to destino, notice: "Custos de #{nome_do_mes} salvos.", status: :see_other
    else
      redirect_to destino, alert: fechamento.errors.full_messages.to_sentence, status: :see_other
    end
  end
end
