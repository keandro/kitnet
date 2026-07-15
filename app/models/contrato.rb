class Contrato < ApplicationRecord
  enum :status, { ativo: 0, encerrado: 1, cancelado: 2 }

  belongs_to :morador, class_name: "Pessoa"
  belongs_to :unidade

  has_many :contrato_fiadores, dependent: :destroy
  has_many :fiadores, through: :contrato_fiadores, source: :pessoa

  validates :data_inicio, presence: true
  validates :valor_aluguel, numericality: { greater_than: 0 }
  validate :pelo_menos_um_fiador

  private

  def pelo_menos_um_fiador
    errors.add(:fiadores, "deve ter pelo menos um fiador") if fiadores.empty?
  end
end
