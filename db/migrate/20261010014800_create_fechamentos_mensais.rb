class CreateFechamentosMensais < ActiveRecord::Migration[8.1]
  def change
    create_table :fechamentos_mensais do |t|
      t.integer :ano, null: false
      t.integer :mes, null: false
      t.decimal :despesas_gerais, precision: 10, scale: 2, null: false, default: 0
      t.decimal :agua_esgoto, precision: 10, scale: 2, null: false, default: 0
      t.decimal :energia_solar, precision: 10, scale: 2

      t.timestamps
    end
    add_index :fechamentos_mensais, [ :ano, :mes ], unique: true
  end
end
