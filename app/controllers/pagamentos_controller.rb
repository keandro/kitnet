class PagamentosController < ApplicationController
  before_action :set_contrato, only: %i[ index new create ]
  before_action :set_pagamento, only: %i[ show edit update destroy ]

  # GET /contratos/:contrato_id/pagamentos
  def index
    @pagamentos = policy_scope(@contrato.pagamentos).order(data_vencimento: :desc)
  end

  # GET /pagamentos/1
  def show
  end

  # GET /contratos/:contrato_id/pagamentos/new
  def new
    @pagamento = @contrato.pagamentos.new(data_vencimento: proxima_data_vencimento, valor: @contrato.valor_aluguel)
    authorize @pagamento
  end

  # GET /pagamentos/1/edit
  def edit
  end

  # POST /contratos/:contrato_id/pagamentos
  def create
    @pagamento = @contrato.pagamentos.new(pagamento_params)
    authorize @pagamento

    if @pagamento.save
      redirect_to contrato_path(@contrato), notice: "Pagamento registrado com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /pagamentos/1
  def update
    if @pagamento.update(pagamento_params)
      redirect_to contrato_path(@pagamento.contrato), notice: "Pagamento atualizado com sucesso.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /pagamentos/1
  def destroy
    contrato = @pagamento.contrato
    @pagamento.destroy!
    redirect_to contrato_path(contrato), notice: "Pagamento removido com sucesso.", status: :see_other
  end

  private
    def set_contrato
      @contrato = Contrato.find(params[:contrato_id])
    end

    def set_pagamento
      @pagamento = Pagamento.find(params[:id])
      authorize @pagamento
      @contrato = @pagamento.contrato
    end

    def pagamento_params
      params.expect(pagamento: [ :valor, :data_vencimento, :data_pagamento, :observacoes ])
    end

    def proxima_data_vencimento
      hoje = Date.current
      dia = @contrato.dia_pagamento || hoje.day
      mes_referencia = hoje.day > dia ? hoje.next_month : hoje
      Date.new(mes_referencia.year, mes_referencia.month, [ dia, Date.new(mes_referencia.year, mes_referencia.month, -1).day ].min)
    end
end
