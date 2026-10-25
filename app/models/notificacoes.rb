# Avisos da página Finanças, sempre em relação a hoje:
# - kitnets a pagar: aluguel sem pagamento no mês, a partir de 5 dias antes do
#   vencimento (dia do contrato ativo ou, sem contrato, o dia do pagamento da
#   kitnet); o mês passado sem pagamento aparece como vencido;
# - energia a pagar: leitura com valor e sem pagamento, que vence no dia do
#   aluguel da kitnet no próprio mês da conta;
# - contratos a vencer: ativos que terminam nos próximos 3 meses ou já terminaram;
# - outros: reservado para avisos futuros.
class Notificacoes
  ANTECEDENCIA = 5 # dias
  MESES_CONTRATO = 3

  Aviso = Data.define(:titulo, :detalhe, :vencimento, :caminho)

  include Rails.application.routes.url_helpers

  attr_reader :hoje

  def initialize(hoje = Date.current)
    @hoje = hoje
    @limite = hoje + ANTECEDENCIA
    @contratos = Contrato.ativo.includes(:unidade).index_by(&:unidade_id)
  end

  def kitnets
    @kitnets ||= begin
      meses = [ @hoje.prev_month.beginning_of_month, @hoje.beginning_of_month ]
      pagos = meses.index_with { |mes| Pagamento.do_mes(mes).distinct.pluck(:unidade_id).to_set }

      Unidade.em_uso.where.not(valor_base: nil).order(:nome).flat_map do |unidade|
        contrato = @contratos[unidade.id]
        dia = contrato&.dia_vencimento || unidade.dia_pagamento
        next [] unless dia

        meses.filter_map do |mes|
          vencimento = no_dia(mes, dia)
          next if pagos[mes].include?(unidade.id) || vencimento > @limite
          next if contrato&.data_inicio && vencimento < contrato.data_inicio

          valor = contrato&.valor || unidade.valor_base
          Aviso.new(titulo: "Kitnet #{unidade.nome}", detalhe: [ contrato&.inquilino, ActiveSupport::NumberHelper.number_to_currency(valor) ].compact.join(" · "),
                    vencimento: vencimento, caminho: new_pagamento_path(unidade_id: unidade.id, data: [ vencimento, @hoje ].min))
        end
      end.sort_by(&:vencimento)
    end
  end

  def energia
    @energia ||= LeituraEnergia.where(data_pagamento: nil).includes(:unidade, :conta_energia).filter_map do |leitura|
      next unless leitura.valor&.positive?

      conta = leitura.conta_energia
      dia = @contratos[leitura.unidade_id]&.dia_vencimento || leitura.unidade.dia_pagamento
      mes = Date.new(conta.ano, conta.mes)
      vencimento = dia ? no_dia(mes, dia) : mes.end_of_month
      next if vencimento > @limite

      Aviso.new(titulo: "Kitnet #{leitura.unidade.nome}",
                detalhe: "#{I18n.t("date.month_names")[conta.mes]}/#{conta.ano} · #{ActiveSupport::NumberHelper.number_to_currency(leitura.valor)}",
                vencimento: vencimento, caminho: energia_path(ano: conta.ano, mes: conta.mes))
    end.sort_by(&:vencimento)
  end

  def contratos
    @contratos_a_vencer ||= @contratos.values.select { |c| c.data_fim && c.data_fim <= @hoje.advance(months: MESES_CONTRATO) }
                                      .sort_by(&:data_fim).map do |contrato|
      Aviso.new(titulo: contrato.inquilino, detalhe: "Kitnet #{contrato.unidade.nome} · início #{I18n.l(contrato.data_inicio)}",
                vencimento: contrato.data_fim, caminho: edit_contrato_path(contrato))
    end
  end

  # Espaço para um próximo tipo de aviso.
  def outros
    []
  end

  def total
    kitnets.size + energia.size + contratos.size + outros.size
  end

  private

  # O dia no mês, ou o último dia em meses mais curtos.
  def no_dia(mes, dia)
    mes.change(day: [ dia, mes.end_of_month.day ].min)
  end
end
