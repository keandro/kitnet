# O endereço do inquilino passa a ser a própria kitnet; qualificação e data
# de assinatura saem (ficam para completar à mão no papel).
class SimplificarDadosDoContratoEscrito < ActiveRecord::Migration[8.1]
  def change
    change_table :contratos, bulk: true do |t|
      t.remove :inquilino_nacionalidade, :inquilino_estado_civil, :inquilino_profissao, :inquilino_endereco, type: :string
      t.remove :fiador_nacionalidade, :fiador_estado_civil, :fiador_profissao, type: :string
      t.remove :data_assinatura, type: :date
    end
  end
end
