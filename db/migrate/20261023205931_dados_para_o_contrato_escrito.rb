# Dados que o contrato escrito pede: qualificação do inquilino e do fiador,
# data da assinatura e, numa configuração única, os dados fixos (locador,
# imóvel, forma de pagamento, foro e taxa de limpeza).
class DadosParaOContratoEscrito < ActiveRecord::Migration[8.1]
  def change
    change_table :contratos, bulk: true do |t|
      t.string :inquilino_nacionalidade
      t.string :inquilino_estado_civil
      t.string :inquilino_profissao
      t.string :inquilino_cpf
      t.string :inquilino_rg
      t.string :inquilino_endereco
      t.string :fiador_nacionalidade
      t.string :fiador_estado_civil
      t.string :fiador_profissao
      t.string :fiador_cpf
      t.string :fiador_rg
      t.string :fiador_endereco
      t.date :data_assinatura
    end

    create_table :configuracoes_contrato do |t|
      t.string :locador_nome
      t.string :locador_qualificacao
      t.string :locador_cpf
      t.string :locador_endereco
      t.string :imovel_endereco
      t.string :imovel_bairro_cidade
      t.text :forma_pagamento
      t.string :cidade_assinatura
      t.string :foro
      t.decimal :taxa_limpeza, precision: 10, scale: 2

      t.timestamps
    end
  end
end
