class AddSemFiadorToContratos < ActiveRecord::Migration[8.1]
  def change
    add_column :contratos, :sem_fiador, :boolean, default: false, null: false
  end
end
