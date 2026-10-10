class PagamentosController < ApplicationController
  before_action :set_contrato, only: %i[ index new ], if: -> { params[:contrato_id].present? }
  before_action :set_pagamento, only: %i[ show edit update destroy ]

  # GET /pagamentos
  # GET /pagamentos?contrato_id=1
  def index
    scope = @contrato ? @contrato.pagamentos : Pagamento.all
    @pagamentos = policy_scope(scope).includes(contrato: :morador).order(data_vencimento: :desc)
  end

  # GET /pagamentos/1
  def show
  end

  # GET /pagamentos/new
  # GET /pagamentos/new?contrato_id=1
  def new
    @pagamento = Pagamento.new(
      contrato_id: params[:contrato_id],
      valor: @contrato&.valor_aluguel,
      data_vencimento: @contrato&.proxima_data_vencimento
    )
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
      redirect_to contrato_path(@pagamento.contrato), notice: "Pagamento registrado com sucesso."
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
    end

    def pagamento_params
      params.expect(pagamento: [ :contrato_id, :valor, :data_vencimento, :data_pagamento, :observacoes ])
    end
end
