# Uma das kitnets (fixas; criadas pelo seed). Guarda o valor base do aluguel e o
# dia do pagamento, que sugerem o valor e a data de cada pagamento; kitnet sem
# valor base não é cobrada.
# "Descontinuada" marca unidades que não são mais alugadas (a antiga casa),
# mas que guardam pagamentos do passado.
class Unidade < ApplicationRecord
  include ValorMonetario
  valor_monetario :valor_base

  scope :em_uso, -> { where(descontinuada: false) }

  # Unidades que aparecem nas telas de um mês: as em uso e as descontinuadas
  # até o mês do último pagamento delas.
  scope :do_mes, ->(data) {
    em_uso.or(where(id: Pagamento.where(data_pagamento: data.beginning_of_month..).select(:unidade_id)))
  }

  has_many :pagamentos, dependent: :restrict_with_error
  has_many :contratos, dependent: :restrict_with_error
  has_many :leituras_energia, class_name: "LeituraEnergia", dependent: :restrict_with_error

  # Valor base zerado é o mesmo que não ter valor base.
  before_validation { self.valor_base = nil if valor_base&.zero? }

  validates :nome, presence: true

  def contrato_ativo
    contratos.find(&:ativo?)
  end
  validates :valor_base, numericality: { greater_than: 0 }, allow_nil: true
  validates :dia_pagamento, numericality: { only_integer: true, in: 1..31, message: "deve ser de 1 a 31" }, allow_nil: true

  # Data sugerida para um pagamento no mês de referência: o dia do pagamento
  # (no último dia, em meses mais curtos), mas nunca depois de hoje.
  def data_de_pagamento(referencia = Date.current)
    data = dia_pagamento ? referencia.change(day: [ dia_pagamento, referencia.end_of_month.day ].min) : referencia
    [ data, Date.current ].min
  end
end
