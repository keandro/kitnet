class EnergiaSolarController < ApplicationController
  before_action :set_apuracao

  # GET /energia-solar?ano=2026&mes=10
  def index
    @lucros = EnergiaSolarMensal.lucros_do_ano(@apuracao.ano)
  end

  # PATCH /energia-solar/2026/10
  def update
    if @apuracao.update(apuracao_params)
      redirect_to energia_solar_path(ano: @apuracao.ano, mes: @apuracao.mes), notice: "Energia solar salva.", status: :see_other
    else
      index
      render :index, status: :unprocessable_content
    end
  end

  private
    def set_apuracao
      hoje = Date.current
      ano = params[:ano].present? ? params[:ano].to_i : hoje.year
      mes = params[:mes].present? ? params[:mes].to_i : hoje.month
      raise ActionController::RoutingError, "Mês inválido" unless ano.between?(2000, 2100) && mes.between?(1, 12)

      @apuracao = EnergiaSolarMensal.do_mes(ano, mes)
    end

    def apuracao_params
      params.expect(energia_solar_mensal: [ :valor_apartamento, :pago_apartamento, :pago_kitnets ])
    end
end
