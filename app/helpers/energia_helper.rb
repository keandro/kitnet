module EnergiaHelper
  # 1234.5 -> "1.234,5"
  def kwh(valor)
    return "—" if valor.nil?

    number_with_precision(valor, precision: 2, strip_insignificant_zeros: true, delimiter: ".", separator: ",")
  end

  # Valor para campos numéricos sem zeros sobrando: 100.0 -> "100", 300.50 -> "300.5"
  def numero_para_campo(valor)
    valor&.to_d&.to_s("F")&.sub(/\.?0+\z/, "")
  end

  def nome_do_mes_energia(conta)
    "#{I18n.t("date.month_names")[conta.mes].capitalize} de #{conta.ano}"
  end
end
