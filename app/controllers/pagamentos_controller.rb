class PagamentosController < ApplicationController
  # As ordens de pagamento são criadas pelo Contrato (uma por mês) e listadas
  # na página dele; aqui elas só são editadas (juros, multa, observações),
  # quitadas ou removidas.
  before_action :set_pagamento

  # GET /pagamentos/1/edit
  def edit
  end

  # PATCH/PUT /pagamentos/1
  def update
    if @pagamento.update(pagamento_params)
      redirect_to contrato_path(@pagamento.contrato), notice: "Pagamento atualizado com sucesso.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # PATCH /pagamentos/1/pagar
  def pagar
    @pagamento.update!(data_pagamento: Date.current)
    redirect_back_or_to contrato_path(@pagamento.contrato), notice: "Pagamento de #{l(@pagamento.data_vencimento)} marcado como pago.", status: :see_other
  end

  # DELETE /pagamentos/1
  def destroy
    contrato = @pagamento.contrato
    @pagamento.destroy!
    redirect_to contrato_path(contrato), notice: "Pagamento removido com sucesso.", status: :see_other
  end

  private
    def set_pagamento
      @pagamento = Pagamento.find(params[:id])
      authorize @pagamento
    end

    def pagamento_params
      params.expect(pagamento: [ :valor, :data_vencimento, :data_pagamento, :observacoes ])
    end
end
