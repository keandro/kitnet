class Contrato < ApplicationRecord
  enum :status, { ativo: 0, encerrado: 1, cancelado: 2 }

  belongs_to :morador, class_name: "Pessoa"
  belongs_to :unidade

  has_many :contrato_fiadors, dependent: :destroy
  has_many :fiadores, through: :contrato_fiadors, source: :pessoa

  accepts_nested_attributes_for :contrato_fiadors, allow_destroy: true

  validates :data_inicio, presence: true
  validates :valor_aluguel, numericality: { greater_than: 0 }
  validate :pelo_menos_um_fiador

  private

  def pelo_menos_um_fiador
    if contrato_fiadors.reject(&:marked_for_destruction?).empty?
      errors.add(:fiadores, "deve ter pelo menos um fiador")
    end
  end
end
