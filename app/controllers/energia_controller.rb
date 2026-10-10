class EnergiaController < ApplicationController
  before_action :set_conta, except: :pagar

  # GET /energia?ano=2026&mes=10
  def index
    @unidades = Unidade.order(:nome)
    @leituras = @conta.leituras.includes(:unidade).index_by(&:unidade_id)
    @moradores = Contrato.ativo.includes(:morador).to_h { |c| [ c.unidade_id, c.morador ] }
  end

  # PATCH /energia/2026/10
  def update
    if @conta.update(conta_params)
      redirect_to energia_path(ano: @conta.ano, mes: @conta.mes), notice: "Conta de energia salva.", status: :see_other
    else
      index
      render :index, status: :unprocessable_content
    end
  end

  # GET /energia/2026/10/leituras
  def edit_leituras
    @unidades = Unidade.order(:nome)
    @leituras = leituras_para_formulario
  end

  # PATCH /energia/2026/10/leituras
  def update_leituras
    @unidades = Unidade.order(:nome)
    @leituras = leituras_para_formulario
    salvo = false

    ActiveRecord::Base.transaction do
      @conta.save! if @conta.new_record?
      @unidades.each do |unidade|
        attrs = params.dig(:leituras, unidade.id.to_s)&.permit(:leitura_anterior, :leitura_atual, :data_pagamento) || {}
        leitura = @leituras[unidade.id]
        leitura.conta_energia = @conta

        if attrs.values.all?(&:blank?)
          leitura.destroy! if leitura.persisted?
        else
          leitura.assign_attributes(attrs)
          leitura.save
        end
      end

      salvo = @leituras.values.all? { |l| l.errors.empty? }
      raise ActiveRecord::Rollback unless salvo
    end

    if salvo
      redirect_to energia_path(ano: @conta.ano, mes: @conta.mes), notice: "Leituras salvas.", status: :see_other
    else
      render :edit_leituras, status: :unprocessable_content
    end
  end

  # PATCH /energia/leituras/1/pagar
  def pagar
    leitura = LeituraEnergia.find(params[:id])
    leitura.update!(data_pagamento: Date.current)
    redirect_to energia_path(ano: leitura.conta_energia.ano, mes: leitura.conta_energia.mes),
                notice: "Energia da kitnet #{leitura.unidade.nome} marcada como paga.", status: :see_other
  end

  private
    def set_conta
      hoje = Date.current
      ano = params[:ano].present? ? params[:ano].to_i : hoje.year
      mes = params[:mes].present? ? params[:mes].to_i : hoje.month
      raise ActionController::RoutingError, "Mês inválido" unless ano.between?(2000, 2100) && mes.between?(1, 12)

      @conta = ContaEnergia.do_mes(ano, mes)
    end

    def conta_params
      params.expect(conta_energia: [ :kwh_total, :valor_total ])
    end

    # Uma leitura por kitnet; as novas já vêm com a leitura anterior igual à
    # leitura atual do mês passado.
    def leituras_para_formulario
      existentes = @conta.leituras.index_by(&:unidade_id)
      anteriores = (@conta.mes_anterior&.leituras || []).index_by(&:unidade_id)

      @unidades.to_h do |unidade|
        [ unidade.id, existentes[unidade.id] || LeituraEnergia.new(unidade: unidade, leitura_anterior: anteriores[unidade.id]&.leitura_atual) ]
      end
    end
end
