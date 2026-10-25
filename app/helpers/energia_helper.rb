module EnergiaHelper
  # 1234.5 -> "1.234,5"
  def kwh(valor)
    return "—" if valor.nil?

    number_with_precision(valor, precision: 2, strip_insignificant_zeros: true, delimiter: ".", separator: ",")
  end

  # Valor para campos numéricos sem zeros sobrando: 100.0 -> "100", 300.50 -> "300.5"
  # Valor do kWh no campo: "1,106006", sem os zeros do fim (mas com 2 casas no mínimo).
  def valor_kwh_para_campo(valor)
    return if valor.nil?

    number_with_precision(valor, precision: 6, separator: ",", delimiter: "").sub(/(,\d\d\d*?)0+\z/, '\\1')
  end

  def numero_para_campo(valor)
    valor&.to_d&.to_s("F")&.sub(/\.?0+\z/, "")
  end

  # Mensagem da conta de energia de uma kitnet, para mandar ao locatário.
  def mensagem_energia(leitura, contrato)
    conta = leitura.conta_energia
    saudacao = contrato ? "Olá, #{contrato.inquilino.split.first}!" : "Olá!"
    [
      saudacao,
      "Segue a conta de energia da kitnet #{leitura.unidade.nome} referente a #{nome_do_mes_energia(conta).downcase}:",
      "",
      "• Leitura anterior: #{kwh(leitura.leitura_anterior)} kWh",
      "• Leitura atual: #{kwh(leitura.leitura_atual)} kWh",
      "• Consumo: #{kwh(leitura.consumo)} kWh",
      "• Valor do kWh: #{number_to_currency(conta.valor_kwh, precision: 4)}",
      "",
      "*Total a pagar: #{number_to_currency(leitura.valor)}*",
      (leitura.pago? ? "(pagamento recebido em #{l(leitura.data_pagamento)} — obrigado!)" : nil)
    ].compact.join("\n")
  end

  # Link do WhatsApp com a mensagem pronta; sem número, o WhatsApp pede o contato.
  def whatsapp_url(celular, texto)
    destino = celular.present? ? "55#{celular}" : ""
    "https://wa.me/#{destino}?text=#{ERB::Util.url_encode(texto)}"
  end

  def nome_do_mes_energia(conta)
    "#{I18n.t("date.month_names")[conta.mes].capitalize} de #{conta.ano}"
  end
end
