# Dados fixos do contrato escrito (imóvel, foro, taxa) e o
# texto do contrato.
class ConfiguracoesContratoController < ApplicationController
  before_action { @configuracao = ConfiguracaoContrato.atual }

  # GET /contratos/modelo/edit
  def edit
  end

  # PATCH /contratos/modelo
  def update
    dados = params.expect(configuracao_contrato: [ :imovel_endereco, :imovel_bairro_cidade, :cidade_assinatura, :foro, :taxa_limpeza, :texto_modelo ])
    dados[:texto_modelo] = nil if params[:restaurar].present?

    if @configuracao.update(dados)
      aviso = params[:restaurar].present? ? "Texto do contrato restaurado ao original." : "Modelo do contrato salvo."
      redirect_to edit_modelo_de_contrato_path, notice: aviso, status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # GET /contratos/modelo/exemplo.pdf — o texto salvo com dados de exemplo.
  def exemplo
    unidade = Unidade.em_uso.order(:nome).first
    contrato = Contrato.new(unidade: unidade, locador: Locador.ordenados.first, inquilino: "NOME DO LOCATÁRIO", fiador: "NOME DO FIADOR",
                            valor: unidade&.valor_base, duracao_meses: 12, dia_vencimento: 10)
    send_data ContratoPdf.new(contrato, @configuracao).render, filename: "contrato-exemplo.pdf",
                                                               type: "application/pdf", disposition: "inline"
  end
end
