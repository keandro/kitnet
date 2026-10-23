# Contratos de aluguel. Ficam separados dos pagamentos: não geram cobranças.
class ContratosController < ApplicationController
  before_action :set_contrato, only: %i[ edit update destroy finalizar pdf para_assinar ]

  # GET /contratos?situacao=ativo|finalizado|todos
  def index
    @situacao = %w[ativo finalizado todos].include?(params[:situacao]) ? params[:situacao] : "ativo"
    escopo = Contrato.includes(:unidade).recentes
    @contratos = @situacao == "todos" ? escopo : escopo.where(status: @situacao)
    @totais = Contrato.group(:status).count
    @com_pdf = ContratoDocumento.pluck(:contrato_id).to_set
  end

  # GET /contratos/1/contrato.pdf — abre o PDF no navegador.
  def pdf
    documento = @contrato.documento
    return head(:not_found) unless documento

    send_data documento.dados, filename: documento.nome, type: "application/pdf", disposition: "inline"
  end

  # GET /contratos/1/para-assinar.pdf — o contrato escrito, pronto para imprimir e assinar.
  def para_assinar
    documento = ContratoPdf.new(@contrato)
    send_data documento.render, filename: documento.nome_do_arquivo, type: "application/pdf", disposition: "inline"
  end

  # GET /contratos/new?unidade_id=1
  def new
    unidade = Unidade.find_by(id: params[:unidade_id])
    @contrato = Contrato.new(unidade: unidade, valor: unidade&.valor_base, duracao_meses: 30, dia_vencimento: 10, data_inicio: Date.current)
  end

  # GET /contratos/1/edit
  def edit
  end

  # POST /contratos
  def create
    @contrato = Contrato.new(contrato_params)
    if @contrato.save
      redirect_to contratos_path, notice: "Contrato de #{@contrato.inquilino} (kitnet #{@contrato.unidade.nome}) criado.", status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH /contratos/1
  def update
    if @contrato.update(contrato_params)
      redirect_to contratos_path(situacao: @contrato.status), notice: "Contrato atualizado.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # PATCH /contratos/1/finalizar
  def finalizar
    @contrato.finalizado!
    redirect_back_or_to contratos_path, notice: "Contrato de #{@contrato.inquilino} finalizado; a kitnet #{@contrato.unidade.nome} ficou livre.", status: :see_other
  end

  # DELETE /contratos/1
  def destroy
    @contrato.destroy!
    redirect_to contratos_path(situacao: @contrato.status), notice: "Contrato removido.", status: :see_other
  end

  private
    def set_contrato
      @contrato = Contrato.find(params.expect(:id))
    end

    def contrato_params
      params.expect(contrato: [ :unidade_id, :inquilino, :celular, :fiador, :valor, :duracao_meses, :dia_vencimento, :data_inicio, :status, :observacoes, :arquivo_pdf, :remover_pdf,
                                        :inquilino_cpf, :inquilino_rg, :fiador_cpf, :fiador_rg, :fiador_endereco,
                                        :inquilino_nacionalidade, :inquilino_estado_civil, :inquilino_profissao, :fiador_nacionalidade, :fiador_estado_civil, :fiador_profissao ])
    end
end
