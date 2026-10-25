# Quando o valor do contrato foi atualizado pela última vez (aviso de aniversário).
class ReajusteDoContrato < ActiveRecord::Migration[8.1]
  def change
    add_column :contratos, :reajustado_em, :date
  end
end
