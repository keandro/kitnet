class QualificacaoNoContratoEscrito < ActiveRecord::Migration[8.1]
  def change
    change_table :contratos, bulk: true do |t|
      t.string :inquilino_nacionalidade, :inquilino_estado_civil, :inquilino_profissao
      t.string :fiador_nacionalidade, :fiador_estado_civil, :fiador_profissao
    end
  end
end
