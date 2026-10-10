class PagamentosController < ApplicationController
  before_action :set_pagamento, only: %i[ edit update destroy ]

  # GET /?ano=2026&mes=10 — pagamentos do mês, por kitnet.
  def index
    hoje = Date.current
    ano = params[:ano].present? ? params[:ano].to_i : hoje.year
    mes = params[:mes].present? ? params[:mes].to_i : hoje.month
    raise ActionController::RoutingError, "Mês inválido" unless ano.between?(2000, 2100) && mes.between?(1, 12)

    @mes = Date.new(ano, mes)
    @unidades = policy_scope(Unidade).order(:nome)
    @pagamentos = policy_scope(Pagamento).do_mes(@mes).includes(:unidade).order(:data_pagamento, :id)
    @por_unidade = @pagamentos.group_by(&:unidade_id)
  end

  # GET /pagamentos/new?unidade_id=1&data=2026-10-05
  def new
    unidade = Unidade.find_by(id: params[:unidade_id])
    data = Date.parse(params[:data].to_s) rescue nil
    @pagamento = Pagamento.new(unidade: unidade, valor: unidade&.valor_base, data_pagamento: [ data || Date.current, Date.current ].min)
    authorize @pagamento
  end

  # GET /pagamentos/1/edit
  def edit
  end

  # POST /pagamentos
  def create
    @pagamento = Pagamento.new(pagamento_params)
    authorize @pagamento

    if @pagamento.save
      redirect_to mes_do(@pagamento), notice: "Pagamento da kitnet #{@pagamento.unidade.nome} registrado.", status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH /pagamentos/1
  def update
    if @pagamento.update(pagamento_params)
      redirect_to mes_do(@pagamento), notice: "Pagamento atualizado.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /pagamentos/1
  def destroy
    @pagamento.destroy!
    redirect_to mes_do(@pagamento), notice: "Pagamento removido.", status: :see_other
  end

  private
    def set_pagamento
      @pagamento = Pagamento.find(params.expect(:id))
      authorize @pagamento
    end

    def pagamento_params
      params.expect(pagamento: [ :unidade_id, :valor, :data_pagamento, :observacoes ])
    end

    def mes_do(pagamento)
      root_path(ano: pagamento.data_pagamento.year, mes: pagamento.data_pagamento.month)
    end
end
