# Contrato de aluguel de uma kitnet. Não gera pagamentos: serve para saber
# quem ocupa cada kitnet, por quanto e até quando.
class Contrato < ApplicationRecord
  include ValorMonetario
  valor_monetario :valor

  enum :status, { ativo: 0, finalizado: 1 }

  belongs_to :unidade

  normalizes :inquilino, :fiador, with: ->(nome) { nome.squish.presence }

  validates :inquilino, presence: true
  validates :valor, numericality: { greater_than: 0 }
  validates :duracao_meses, numericality: { only_integer: true, in: 1..120 }
  validates :dia_vencimento, numericality: { only_integer: true, in: 1..31 }
  validate :uma_kitnet_um_contrato_ativo, if: :ativo?

  scope :recentes, -> { order(Arel.sql("status, COALESCE(data_inicio, created_at) DESC")) }

  def data_fim
    data_inicio&.advance(months: duracao_meses)&.prev_day
  end

  def meses_restantes
    return unless ativo? && data_fim

    hoje = Date.current
    return 0 if data_fim < hoje

    (data_fim.year * 12 + data_fim.month) - (hoje.year * 12 + hoje.month)
  end

  private

  def uma_kitnet_um_contrato_ativo
    outro = Contrato.ativo.where(unidade_id: unidade_id).where.not(id: id).first
    errors.add(:unidade, "#{unidade&.nome} já tem um contrato ativo (#{outro.inquilino}). Finalize-o antes.") if outro
  end
end
