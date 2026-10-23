# Texto do contrato para assinar, editável em Contratos → Modelo do contrato.
# Cada linha é um parágrafo:
#   # Título          título do contrato (centralizado)
#   ## Título         título de seção
#   > Texto           parágrafo com recuo
#   1- Texto          cláusula; os números são refeitos em ordem
#   a) Texto          item de uma lista
#   **negrito**  __sublinhado__  {campo}
#   [se tiver fiador] … [fim]   (também "se não tiver" e "taxa de limpeza")
class ModeloDeContrato
  ARQUIVO_PADRAO = Rails.root.join("config/contrato_padrao.txt")

  CAMPOS = {
    "Locador" => %w[locador locador_qualificacao locador_cpf locador_endereco],
    "Locatário" => %w[locatario locatario_nacionalidade locatario_estado_civil locatario_profissao locatario_cpf locatario_rg locatario_endereco],
    "Fiador" => %w[fiador fiador_nacionalidade fiador_estado_civil fiador_profissao fiador_cpf fiador_identidade fiador_endereco],
    "Imóvel" => %w[imovel_endereco andar kitnet bairro_cidade],
    "Aluguel e prazo" => %w[valor valor_extenso dia_vencimento dia_vencimento_extenso forma_pagamento duracao duracao_extenso inicio termino],
    "Outros" => %w[taxa_limpeza taxa_limpeza_extenso foro cidade]
  }.freeze
  NOMES_DOS_CAMPOS = CAMPOS.values.flatten.to_set.freeze

  CONDICAO = /\A\[se (n[ãa]o )?tiver (fiador|taxa de limpeza)\]\z/i
  FIM = /\A\[fim\]\z/i
  CAMPO = /\{([a-z_]+)\}/

  def self.padrao = File.read(ARQUIVO_PADRAO)

  def initialize(texto)
    @texto = texto.to_s
  end

  def erros
    erros = []
    abertas = 0
    linhas.each_with_index do |linha, i|
      if linha.match?(CONDICAO)
        abertas += 1
      elsif linha.match?(FIM)
        abertas.zero? ? erros << "linha #{i + 1}: [fim] sem um [se tiver …] antes" : abertas -= 1
      elsif linha.start_with?("[") && linha.end_with?("]")
        erros << "linha #{i + 1}: #{linha} não é reconhecido (use [se tiver fiador], [se tiver taxa de limpeza] ou [fim])"
      end
      linha.scan(CAMPO).flatten.reject { |campo| NOMES_DOS_CAMPOS.include?(campo) }.each do |campo|
        erros << "linha #{i + 1}: o campo {#{campo}} não existe"
      end
    end
    erros << "falta [fim] para fechar #{abertas} [se tiver …]" if abertas.positive?
    erros
  end

  # [tipo, texto] na ordem do contrato, só com as partes que valem para estas
  # condições ({ "fiador" => true, "taxa de limpeza" => false }). Os números
  # das cláusulas já vêm refeitos.
  def blocos(condicoes)
    valendo = []
    numero = 0
    linhas.filter_map do |linha|
      if (se = linha.match(CONDICAO))
        valendo << (condicoes[se[2].downcase] ^ se[1].present?)
        next
      elsif linha.match?(FIM)
        valendo.pop
        next
      end
      next if linha.empty? || !valendo.all?

      case linha
      when /\A##\s*(.+)/ then [ :titulo, $1 ]
      when /\A#\s*(.+)/ then [ :titulo_principal, $1 ]
      when /\A>\s*(.+)/ then [ :recuado, $1 ]
      when /\A\d+\s*[-–]\s*(.+)/ then [ :clausula, "#{numero += 1}- #{$1}" ]
      when /\A[a-z]\)\s/i then [ :item, linha ]
      else [ :paragrafo, linha ]
      end
    end
  end

  private

  def linhas
    @linhas ||= @texto.lines.map(&:strip)
  end
end
