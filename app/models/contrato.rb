# Contrato de aluguel de uma kitnet. Não gera pagamentos: serve para saber
# quem ocupa cada kitnet, por quanto e até quando.
class Contrato < ApplicationRecord
  include ValorMonetario
  valor_monetario :valor

  enum :status, { ativo: 0, finalizado: 1 }

  belongs_to :unidade
  has_one :documento, class_name: "ContratoDocumento", dependent: :destroy

  # Upload do PDF pelo formulário (arquivo novo ou "remover").
  attr_accessor :arquivo_pdf, :remover_pdf

  normalizes :inquilino, :fiador, with: ->(nome) { nome.squish.presence }
  normalizes :inquilino_nacionalidade, :inquilino_estado_civil, :inquilino_profissao, :inquilino_cpf, :inquilino_rg, :inquilino_endereco,
             :fiador_nacionalidade, :fiador_estado_civil, :fiador_profissao, :fiador_cpf, :fiador_rg, :fiador_endereco,
             with: ->(texto) { texto.squish.presence }
  # Só dígitos, sem o +55: "(27) 99999-9999" e "+55 27 99999-9999" viram "27999999999".
  normalizes :celular, with: ->(numero) {
    digitos = numero.gsub(/\D/, "")
    digitos = digitos.delete_prefix("55") if digitos.length > 11
    digitos.presence
  }

  validates :inquilino, presence: true
  validates :valor, numericality: { greater_than: 0 }
  validates :duracao_meses, numericality: { only_integer: true, in: 1..120 }
  validates :dia_vencimento, numericality: { only_integer: true, in: 1..31 }
  validates :celular, format: { with: /\A[1-9]{2}9\d{8}\z/, message: "precisa ter DDD + 9 dígitos (ex.: (27) 99999-9999)" }, allow_nil: true
  validate :uma_kitnet_um_contrato_ativo, if: :ativo?
  validate :arquivo_pdf_valido, if: -> { arquivo_pdf.present? }

  after_save :salvar_pdf

  scope :recentes, -> { order(Arel.sql("status, COALESCE(data_inicio, created_at) DESC")) }

  # Como nos contratos assinados: início 10/01/2024 + 30 meses = término 10/07/2026.
  def data_fim
    data_inicio&.advance(months: duracao_meses)
  end

  # (27) 99999-9999
  def celular_formatado
    celular&.sub(/\A(\d{2})(\d{5})(\d{4})\z/, '(\\1) \\2-\\3')
  end

  def sem_fiador_no_contrato?
    fiador.blank?
  end

  # Nome e tamanho do PDF, sem carregar o arquivo.
  def documento_info
    return unless persisted?

    @documento_info ||= ContratoDocumento.sem_dados.find_by(contrato_id: id)
  end

  def meses_restantes
    return unless ativo? && data_fim

    hoje = Date.current
    return 0 if data_fim < hoje

    (data_fim.year * 12 + data_fim.month) - (hoje.year * 12 + hoje.month)
  end

  private

  def arquivo_pdf_valido
    if arquivo_pdf.size > ContratoDocumento::TAMANHO_MAXIMO
      errors.add(:arquivo_pdf, "é maior que #{ContratoDocumento::TAMANHO_MAXIMO / 1.megabyte} MB")
    elsif !ContratoDocumento.pdf?(arquivo_pdf.read(5).tap { arquivo_pdf.rewind })
      errors.add(:arquivo_pdf, "precisa ser um arquivo PDF")
    end
  end

  def salvar_pdf
    if arquivo_pdf.present?
      doc = documento || build_documento
      doc.update!(nome: File.basename(arquivo_pdf.original_filename.to_s).presence || "contrato.pdf",
                  tamanho: arquivo_pdf.size, dados: arquivo_pdf.read)
    elsif ActiveModel::Type::Boolean.new.cast(remover_pdf)
      documento&.destroy!
    end
    @documento_info = nil
  end

  def uma_kitnet_um_contrato_ativo
    outro = Contrato.ativo.where(unidade_id: unidade_id).where.not(id: id).first
    errors.add(:unidade, "#{unidade&.nome} já tem um contrato ativo (#{outro.inquilino}). Finalize-o antes.") if outro
  end
end
