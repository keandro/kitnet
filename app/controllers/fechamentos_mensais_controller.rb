class FechamentosMensaisController < ApplicationController
  before_action :set_fechamento

  # GET /financas/2026/10/editar
  def edit
  end

  # PATCH /financas/2026/10
  def update
    if @fechamento.update(fechamento_params)
      redirect_to financas_path(ano: @fechamento.ano), notice: "Valores de #{nome_do_mes} atualizados.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_fechamento
      @fechamento = FechamentoMensal.find_or_initialize_by(ano: params[:ano].to_i, mes: params[:mes].to_i)
      raise ActionController::RoutingError, "Mês inválido" unless @fechamento.ano.between?(2000, 2100) && @fechamento.mes.between?(1, 12)
    end

    def fechamento_params
      params.expect(fechamento_mensal: [ :despesas_gerais, :agua_esgoto ])
    end

    def nome_do_mes
      "#{I18n.t("date.month_names")[@fechamento.mes]} de #{@fechamento.ano}"
    end
end
