# Aluguel recebido de uma kitnet: valor (sugerido pelo valor base da kitnet),
# data do pagamento e observações.
class Pagamento < ApplicationRecord
  include ValorMonetario
  valor_monetario :valor

  belongs_to :unidade

  validates :valor, numericality: { greater_than: 0 }
  validates :data_pagamento, presence: true
  validate :data_pagamento_nao_pode_ser_futura

  scope :do_mes, ->(data) { where(data_pagamento: data.all_month) }

  private

  def data_pagamento_nao_pode_ser_futura
    errors.add(:data_pagamento, "não pode ser no futuro") if data_pagamento && data_pagamento > Date.current
  end
end
