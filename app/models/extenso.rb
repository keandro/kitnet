# Números por extenso em português, para o contrato escrito:
#   Extenso.numero(30)        # => "trinta"
#   Extenso.reais(1050)       # => "um mil e cinquenta reais"
#   Extenso.reais(1035.6)     # => "um mil e trinta e cinco reais e sessenta centavos"
module Extenso
  UNIDADES = %w[zero um dois três quatro cinco seis sete oito nove dez onze doze treze quatorze quinze dezesseis dezessete dezoito dezenove].freeze
  DEZENAS = %w[_ _ vinte trinta quarenta cinquenta sessenta setenta oitenta noventa].freeze
  CENTENAS = %w[_ cento duzentos trezentos quatrocentos quinhentos seiscentos setecentos oitocentos novecentos].freeze

  module_function

  def numero(n)
    n = n.to_i
    return UNIDADES[0] if n.zero?

    milhoes, resto = n.divmod(1_000_000)
    milhares, unidades = resto.divmod(1000)
    grupos = []
    grupos << [ milhoes, "#{ate_999(milhoes)} #{milhoes == 1 ? "milhão" : "milhões"}" ] if milhoes.positive?
    grupos << [ milhares, "#{ate_999(milhares)} mil" ] if milhares.positive?
    grupos << [ unidades, ate_999(unidades) ] if unidades.positive?

    # Entre grupos vai "e" quando o seguinte é menor que 100 ou uma centena
    # redonda ("um mil e cinquenta", "um mil e cem"); senão, vírgula
    # ("um mil, cento e quarenta e oito").
    grupos.each_with_index.reduce("") do |texto, ((valor, palavras), i)|
      next palavras if i.zero?

      ligacao = valor < 100 || (valor % 100).zero? ? " e " : ", "
      texto + ligacao + palavras
    end
  end

  def ate_999(n)
    return "cem" if n == 100

    centena, resto = n.divmod(100)
    partes = []
    partes << CENTENAS[centena] if centena.positive?
    if resto.positive?
      partes << (resto < 20 ? UNIDADES[resto] : [ DEZENAS[resto / 10], (UNIDADES[resto % 10] if (resto % 10).positive?) ].compact.join(" e "))
    end
    partes.join(" e ")
  end

  def reais(valor)
    centavos_total = (BigDecimal(valor.to_s) * 100).round.to_i
    inteiro, centavos = centavos_total.divmod(100)
    partes = []
    partes << "#{numero(inteiro)} #{inteiro == 1 ? "real" : "reais"}" if inteiro.positive?
    partes << "#{numero(centavos)} #{centavos == 1 ? "centavo" : "centavos"}" if centavos.positive?
    partes.empty? ? "zero reais" : partes.join(" e ")
  end
end
