module FinancasHelper
  # Escala do gráfico com marcas redondas, sempre incluindo o zero; desce
  # abaixo de zero quando algum mês fechou no negativo.
  # Retorna { ticks:, minimo:, maximo: }.
  def escala_financas(valores)
    minimo = [ valores.min.to_f, 0 ].min
    maximo = [ valores.max.to_f, 0 ].max
    maximo = 1000.0 if minimo.zero? && maximo.zero?

    bruto = (maximo - minimo) / 4
    magnitude = 10**Math.log10(bruto).floor
    passo = [ 1, 2, 2.5, 5, 10 ].map { |m| m * magnitude }.find { |p| p >= bruto }
    inicio = (minimo / passo).floor * passo
    fim = (maximo / passo).ceil * passo
    ticks = (0..((fim - inicio) / passo).round).map { |i| inicio + i * passo }
    { ticks: ticks, minimo: inicio, maximo: fim }
  end

  # Posição vertical (% a partir da base) de um valor na escala.
  def posicao_na_escala(valor, escala)
    (valor.to_f - escala[:minimo]) / (escala[:maximo] - escala[:minimo]) * 100
  end

  # "R$ 0", "R$ 750", "R$ 1,5 mil", "−R$ 300"
  def dinheiro_compacto(valor)
    sinal = valor.negative? ? "−" : ""
    valor = valor.abs
    if valor >= 1000
      "#{sinal}R$ #{number_with_precision(valor / 1000.0, precision: 1, strip_insignificant_zeros: true, separator: ",")} mil"
    else
      "#{sinal}R$ #{number_with_precision(valor, precision: 0, delimiter: ".")}"
    end
  end

  # Variação em relação ao mês anterior, com seta e texto (nunca só cor).
  def variacao_mensal(atual, anterior, rotulo_anterior, vazio: "sem recebimentos")
    return tag.span("#{vazio} em #{rotulo_anterior}", class: "text-slate-500 dark:text-slate-400") if anterior.to_d.zero?

    pct = ((atual - anterior) / anterior.abs * 100).round
    if pct.positive?
      tag.span("▲ +#{pct}% vs #{rotulo_anterior}", class: "font-medium text-emerald-700 dark:text-emerald-400")
    elsif pct.negative?
      tag.span("▼ #{pct}% vs #{rotulo_anterior}", class: "font-medium text-rose-700 dark:text-rose-400")
    else
      tag.span("= igual a #{rotulo_anterior}", class: "text-slate-500 dark:text-slate-400")
    end
  end

  # Custos e créditos do mês: "— " quando zerado, senão "− R$ 120,00".
  def valor_lancado(valor, sinal:)
    valor.to_d.zero? ? "—" : "#{sinal} #{number_to_currency(valor)}"
  end

  def nome_mes(mes, abreviado: false)
    I18n.t(abreviado ? "date.abbr_month_names" : "date.month_names")[mes]
  end
end
