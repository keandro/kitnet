class Pagamento < ApplicationRecord
  include ValorMonetario
  valor_monetario :valor

  belongs_to :contrato

  validates :valor, numericality: { greater_than: 0 }
  validates :data_vencimento, presence: true
  validate :data_pagamento_nao_pode_ser_futura

  scope :pagos, -> { where.not(data_pagamento: nil) }
  scope :pendentes, -> { where(data_pagamento: nil).where(data_vencimento: Date.current..) }
  scope :vencidos, -> { where(data_pagamento: nil).where(data_vencimento: ...Date.current) }

  def status
    if data_pagamento.present?
      :pago
    elsif data_vencimento < Date.current
      :vencido
    else
      :pendente
    end
  end

  private

  def data_pagamento_nao_pode_ser_futura
    errors.add(:data_pagamento, "não pode ser no futuro") if data_pagamento.present? && data_pagamento > Date.current
  end
end
