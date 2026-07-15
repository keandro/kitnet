class CreateContratos < ActiveRecord::Migration[8.1]
  def change
    create_table :contratos do |t|
      t.references :morador, null: false, foreign_key: { to_table: :pessoas }
      t.references :unidade, null: false, foreign_key: true
      t.date :data_inicio
      t.date :data_fim
      t.decimal :valor_aluguel
      t.integer :status

      t.timestamps
    end
  end
end
