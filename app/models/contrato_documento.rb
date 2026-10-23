# O PDF de um contrato. Os bytes ficam em `dados`; use .sem_dados para
# consultar só nome e tamanho.
class ContratoDocumento < ApplicationRecord
  TAMANHO_MAXIMO = 20.megabytes

  belongs_to :contrato

  scope :sem_dados, -> { select(:id, :contrato_id, :nome, :tamanho, :updated_at) }

  def self.pdf?(bytes)
    bytes.to_s.byteslice(0, 5) == "%PDF-"
  end
end
