module ContratosHelper
  # Opções do select de unidade: as que já têm outro contrato ativo aparecem
  # desabilitadas, com o nome do morador.
  def unidade_options_for_contrato(contrato)
    ocupadas = Contrato.ativo.where.not(id: contrato.id).includes(:morador).index_by(&:unidade_id)

    options = Unidade.order(:nome).map do |unidade|
      ativo = ocupadas[unidade.id]
      label = ativo ? "#{unidade.nome} — ocupada (#{ativo.morador.nome})" : unidade.nome
      [ label, unidade.id, { disabled: ativo.present? } ]
    end

    options_for_select(options, contrato.unidade_id)
  end
end
