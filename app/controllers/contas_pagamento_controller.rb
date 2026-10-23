# Contas para pagamento (banco, agência, conta e Pix).
class ContasPagamentoController < ApplicationController
  before_action :set_conta, only: %i[ edit update destroy ]

  # GET /contas-para-pagamento
  def index
    @contas = ContaPagamento.ordenadas
  end

  # GET /contas-para-pagamento/new
  def new
    @conta = ContaPagamento.new
  end

  # GET /contas-para-pagamento/1/edit
  def edit
  end

  # POST /contas-para-pagamento
  def create
    @conta = ContaPagamento.new(conta_params)
    if @conta.save
      redirect_to contas_pagamento_path, notice: "Conta de #{@conta.titular} adicionada.", status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH /contas-para-pagamento/1
  def update
    if @conta.update(conta_params)
      redirect_to contas_pagamento_path, notice: "Conta atualizada.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /contas-para-pagamento/1
  def destroy
    @conta.destroy!
    redirect_to contas_pagamento_path, notice: "Conta de #{@conta.titular} removida.", status: :see_other
  end

  private
    def set_conta
      @conta = ContaPagamento.find(params.expect(:id))
    end

    def conta_params
      params.expect(conta_pagamento: [ :titular, :banco_codigo, :banco_nome, :agencia, :conta, :chave_pix ])
    end
end
