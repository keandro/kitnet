# Dados fixos do contrato escrito (locador, imóvel, pagamento, foro, taxa).
class ConfiguracoesContratoController < ApplicationController
  before_action { @configuracao = ConfiguracaoContrato.atual }

  # GET /contratos/modelo/edit
  def edit
  end

  # PATCH /contratos/modelo
  def update
    if @configuracao.update(params.expect(configuracao_contrato: [ :locador_nome, :locador_qualificacao, :locador_cpf, :locador_endereco,
                                                                    :imovel_endereco, :imovel_bairro_cidade, :forma_pagamento,
                                                                    :cidade_assinatura, :foro, :taxa_limpeza ]))
      redirect_to contratos_path, notice: "Dados do modelo de contrato salvos.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end
end
