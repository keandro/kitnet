class Contrato < ApplicationRecord
  enum :status, { ativo: 0, encerrado: 1, cancelado: 2 }

  belongs_to :morador, class_name: "Pessoa"
  belongs_to :unidade

  has_many :contrato_fiadores, dependent: :destroy
  has_many :fiadores, through: :contrato_fiadores, source: :pessoa
  has_many :pagamentos, dependent: :destroy

  validates :data_inicio, presence: true
  validates :valor_aluguel, numericality: { greater_than: 0 }
  validates :dia_pagamento, presence: true, inclusion: { in: 1..31 }
  validate :pelo_menos_um_fiador

  after_save :sincronizar_status_da_unidade
  after_destroy :sincronizar_status_da_unidade

  def ultimo_pagamento
    pagamentos.order(:data_vencimento).last
  end

  def status_pagamento
    ultimo_pagamento&.status || :sem_pagamento
  end

  private

  def pelo_menos_um_fiador
    errors.add(:fiadores, "deve ter pelo menos um fiador") if fiadores.empty?
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
end
