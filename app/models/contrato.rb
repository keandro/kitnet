class Contrato < ApplicationRecord
  include ValorMonetario
  valor_monetario :valor_aluguel

  enum :status, { ativo: 0, encerrado: 1, cancelado: 2 }

  belongs_to :morador, class_name: "Pessoa"
  belongs_to :unidade

  has_many :contrato_fiadores, dependent: :destroy
  has_many :fiadores, through: :contrato_fiadores, source: :pessoa
  has_many :pagamentos, dependent: :destroy

  validates :data_inicio, presence: true
  validates :duracao_meses, numericality: { only_integer: true, in: 1..120 }
  validates :valor_aluguel, numericality: { greater_than: 0 }
  validates :dia_pagamento, presence: true, inclusion: { in: 1..31 }
  validate :pelo_menos_um_fiador, unless: :sem_fiador?
  validate :unidade_sem_outro_contrato_ativo, if: :ativo?

  before_validation :calcular_data_fim
  before_validation :remover_fiadores, if: :sem_fiador?

  after_save :sincronizar_status_da_unidade
  after_save :sincronizar_ordens_de_pagamento
  after_destroy :sincronizar_status_da_unidade

  # Resumo da situação financeira: vencido se houver alguma ordem atrasada,
  # pendente se ainda houver ordens em aberto, pago se todas foram quitadas.
  def status_pagamento
    ordens = pagamentos.to_a
    return :sem_pagamento if ordens.empty?

    status = ordens.map(&:status)
    if status.include?(:vencido) then :vencido
    elsif status.include?(:pendente) then :pendente
    else :pago
    end
  end

  # Um vencimento por mês, começando no mês de início do contrato.
  def vencimentos_previstos
    return [] unless data_inicio && duracao_meses && dia_pagamento

    Array.new(duracao_meses) { |i| vencimento_no_mes(data_inicio.advance(months: i)) }
  end

  private

  # Dia de pagamento dentro do mês de `data`, limitado ao último dia do mês
  # (dia 31 vira 28/29 em fevereiro, 30 em abril etc.).
  def vencimento_no_mes(data)
    data.change(day: [ dia_pagamento, data.end_of_month.day ].min)
  end

  def calcular_data_fim
    self.data_fim = data_inicio.advance(months: duracao_meses).prev_day if data_inicio && duracao_meses.to_i.positive?
  end

  def pelo_menos_um_fiador
    errors.add(:fiadores, "deve ter pelo menos um fiador (ou marque \"Sem fiador\")") if fiadores.empty?
  end

  def remover_fiadores
    self.fiadores = []
  end

  # Uma kitnet só pode ter um contrato ativo por vez.
  def unidade_sem_outro_contrato_ativo
    return unless unidade

    outro = unidade.contratos.ativo.where.not(id: id).includes(:morador).first
    errors.add(:unidade, "#{unidade.nome} já tem um contrato ativo (#{outro.morador.nome})") if outro
  end

  # A unidade fica ocupada enquanto tiver algum contrato ativo, e volta a
  # ficar livre assim que o último contrato ativo for encerrado/cancelado/excluído.
  def sincronizar_status_da_unidade
    if persisted? && ativo?
      unidade.update(status: :ocupada)
    elsif unidade.ocupada? && unidade.contratos.ativo.where.not(id: id).none?
      # Só libera automaticamente quem estava ocupada — não mexe em "manutenção",
      # que é um estado definido manualmente.
      unidade.update(status: :livre)
    end
  end

  # Mantém as ordens de pagamento (uma por mês) de acordo com o contrato.
  # Ordens já pagas nunca são alteradas nem removidas.
  def sincronizar_ordens_de_pagamento
    if !ativo?
      # Contrato encerrado/cancelado: as mensalidades futuras deixam de existir;
      # as já vencidas continuam, pois são dívida real.
      pagamentos.where(data_pagamento: nil).where(data_vencimento: Date.current.next_day..).destroy_all if saved_change_to_status?
      return
    end

    # Reajuste do aluguel vale para as ordens futuras em aberto que ainda têm o
    # valor antigo; as que foram alteradas à mão (juros, desconto) ficam como estão.
    if saved_change_to_valor_aluguel? && !previously_new_record?
      valor_antigo, valor_novo = saved_change_to_valor_aluguel
      pagamentos.where(data_pagamento: nil, valor: valor_antigo).where(data_vencimento: Date.current..).update_all(valor: valor_novo)
    end

    # Contratos anteriores às ordens automáticas ganham as suas ao serem salvos.
    return unless previously_new_record? || pagamentos.none? || saved_change_to_status? ||
                  saved_change_to_data_inicio? || saved_change_to_duracao_meses? || saved_change_to_dia_pagamento?

    previstos = vencimentos_previstos.index_by { |data| [ data.year, data.month ] }
    meses_com_ordem = []

    pagamentos.reload.each do |pagamento|
      mes = [ pagamento.data_vencimento.year, pagamento.data_vencimento.month ]

      if pagamento.data_pagamento.present?
        meses_com_ordem << mes
      elsif previstos.key?(mes)
        # Só realinha a data se o dia de pagamento mudou, para não desfazer
        # um vencimento adiado à mão.
        pagamento.update!(data_vencimento: previstos[mes]) if saved_change_to_dia_pagamento?
        meses_com_ordem << mes
      else
        pagamento.destroy!
      end
    end

    previstos.except(*meses_com_ordem).each_value do |vencimento|
      pagamentos.create!(valor: valor_aluguel, data_vencimento: vencimento)
    end
  end
end
