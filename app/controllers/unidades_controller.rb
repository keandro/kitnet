# As kitnets são fixas (criadas pelo seed): aqui só se consulta e se ajusta
# o valor base e o status de cada uma.
class UnidadesController < ApplicationController
  before_action :set_unidade, only: %i[ show edit update ]

  # GET /kitnets
  def index
    unidades = policy_scope(Unidade).order(:nome)
    @grupos = unidades.group_by { |unidade| unidade.nome.to_s[0] }.sort.to_h
    @pagas_no_mes = Pagamento.do_mes(Date.current).distinct.pluck(:unidade_id).to_set
  end

  # GET /kitnets/1
  def show
    @pagamentos = @unidade.pagamentos.order(data_pagamento: :desc)
  end

  # GET /kitnets/1/edit
  def edit
  end

  # PATCH /kitnets/1
  def update
    if @unidade.update(unidade_params)
      redirect_to @unidade, notice: "Kitnet #{@unidade.nome} atualizada.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_unidade
      @unidade = Unidade.find(params.expect(:id))
      authorize @unidade
    end

    def unidade_params
      params.expect(unidade: [ :valor_base, :status ])
    end
end
