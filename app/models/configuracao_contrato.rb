# Dados fixos do contrato escrito (uma configuração só): locador, endereço do
# imóvel, foro, taxa de limpeza e o texto do contrato.
# Ficam no banco, fora do código, porque são dados pessoais.
class ConfiguracaoContrato < ApplicationRecord
  self.table_name = "configuracoes_contrato"

  include ValorMonetario
  valor_monetario :taxa_limpeza

  normalizes :locador_nome, :locador_qualificacao, :locador_cpf, :locador_endereco, :imovel_endereco,
             :imovel_bairro_cidade, :cidade_assinatura, :foro, with: ->(texto) { texto.squish.presence }
  # Igual ao texto padrão fica vazio, para seguir o padrão se ele mudar.
  normalizes :texto_modelo, with: ->(texto) {
    texto = texto.gsub("\r\n", "\n").strip
    texto.presence unless texto == ModeloDeContrato.padrao.strip
  }

  validates :taxa_limpeza, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate { ModeloDeContrato.new(texto_modelo).erros.each { |erro| errors.add(:texto_modelo, erro) } }

  def self.atual
    first || create!
  end

  def texto_do_contrato
    texto_modelo.presence || ModeloDeContrato.padrao
  end
end
