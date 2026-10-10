module PagamentosHelper
  # Opções do select de contrato. Cada opção leva o valor do aluguel e o
  # próximo vencimento, que o pagamento_form_controller usa para pré-preencher.
  def contrato_options_for_pagamento(pagamento)
    contratos = Contrato.includes(:morador, :unidade, :pagamentos).order(:id)

    options = contratos.map do |c|
      [ "#{c.morador.nome} — #{c.unidade.nome}", c.id, { data: { valor: c.valor_aluguel, vencimento: c.proxima_data_vencimento&.iso8601 } } ]
    end

    options_for_select(options, pagamento.contrato_id)
  end
end
