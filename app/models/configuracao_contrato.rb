# Dados fixos do contrato escrito (uma configuração só): locador, endereço do
# imóvel, forma de pagamento, foro e taxa de limpeza. Ficam no banco, fora do
# código, porque são dados pessoais.
class ConfiguracaoContrato < ApplicationRecord
  self.table_name = "configuracoes_contrato"

  include ValorMonetario
  valor_monetario :taxa_limpeza

  normalizes :locador_nome, :locador_qualificacao, :locador_cpf, :locador_endereco, :imovel_endereco,
             :imovel_bairro_cidade, :cidade_assinatura, :foro, with: ->(texto) { texto.squish.presence }
  normalizes :forma_pagamento, with: ->(texto) { texto.strip.presence }

  validates :taxa_limpeza, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def self.atual
    first || create!
  end
end
