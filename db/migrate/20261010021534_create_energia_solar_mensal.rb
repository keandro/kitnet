class CreateEnergiaSolarMensal < ActiveRecord::Migration[8.1]
  def change
    create_table :energia_solar_mensal do |t|
      t.integer :ano, null: false
      t.integer :mes, null: false
      t.decimal :valor_apartamento, precision: 10, scale: 2
      t.decimal :pago_apartamento, precision: 10, scale: 2
      t.decimal :pago_kitnets, precision: 10, scale: 2

      t.timestamps
    end
    add_index :energia_solar_mensal, [ :ano, :mes ], unique: true
  end
end
