module FinancasHelper
  # Valores redondos para o eixo: 0 e mais 4 marcas (ex.: 0, 500, 1.000...).
  def ticks_financas(maximo)
    return [ 0, 250, 500, 750, 1000 ] if maximo.to_d <= 0

    bruto = maximo.to_f / 4
    magnitude = 10**Math.log10(bruto).floor
    passo = [ 1, 2, 2.5, 5, 10 ].map { |m| m * magnitude }.find { |p| p >= bruto }
    (0..4).map { |i| i * passo }
  end

  # "R$ 0", "R$ 750", "R$ 1,5 mil"
  def dinheiro_compacto(valor)
    if valor >= 1000
      "R$ #{number_with_precision(valor / 1000.0, precision: 1, strip_insignificant_zeros: true, separator: ",")} mil"
    else
      "R$ #{number_with_precision(valor, precision: 0, delimiter: ".")}"
    end
  end

  # Variação em relação ao mês anterior, com seta e texto (nunca só cor).
  def variacao_mensal(atual, anterior, rotulo_anterior)
    return tag.span("sem recebimentos em #{rotulo_anterior}", class: "text-slate-500 dark:text-slate-400") if anterior.to_d.zero?

    pct = ((atual - anterior) / anterior * 100).round
    if pct.positive?
      tag.span("▲ +#{pct}% vs #{rotulo_anterior}", class: "font-medium text-emerald-700 dark:text-emerald-400")
    elsif pct.negative?
      tag.span("▼ #{pct}% vs #{rotulo_anterior}", class: "font-medium text-rose-700 dark:text-rose-400")
    else
      tag.span("= igual a #{rotulo_anterior}", class: "text-slate-500 dark:text-slate-400")
    end
  end

  def nome_mes(mes, abreviado: false)
    I18n.t(abreviado ? "date.abbr_month_names" : "date.month_names")[mes]
  end
end
