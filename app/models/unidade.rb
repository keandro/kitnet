class Unidade < ApplicationRecord
  include ValorMonetario
  valor_monetario :valor_base

  enum :status, { livre: 0, ocupada: 1, manutencao: 2 }

  has_many :contratos, dependent: :restrict_with_error
  has_many :leituras_energia, class_name: "LeituraEnergia", dependent: :restrict_with_error

  validates :nome, presence: true
  validates :valor_base, numericality: { greater_than: 0 }, allow_nil: true
  validate :status_ocupada_com_contrato_ativo, if: :will_save_change_to_status?

  def contrato_ativo
    contratos.ativo.first
  end

  def morador_atual
    contrato_ativo&.morador
  end

  private

  # Com contrato ativo a kitnet fica "ocupada" e o status não pode ser trocado
  # à mão; ele volta a mudar quando o contrato é encerrado, cancelado ou excluído.
  def status_ocupada_com_contrato_ativo
    return if ocupada? || new_record?

    ativo = contrato_ativo
    errors.add(:status, "não pode ser alterado enquanto houver contrato ativo (#{ativo.morador.nome})") if ativo
  end
end
