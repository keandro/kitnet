class CreateContasEnergia < ActiveRecord::Migration[8.1]
  def change
    create_table :contas_energia do |t|
      t.integer :ano, null: false
      t.integer :mes, null: false
      t.decimal :kwh_total, precision: 10, scale: 2
      t.decimal :valor_total, precision: 10, scale: 2

      t.timestamps
    end
    add_index :contas_energia, [ :ano, :mes ], unique: true

    create_table :leituras_energia do |t|
      t.references :conta_energia, null: false, foreign_key: { to_table: :contas_energia }
      t.references :unidade, null: false, foreign_key: true
      t.decimal :leitura_anterior, precision: 12, scale: 2
      t.decimal :leitura_atual, precision: 12, scale: 2
      t.date :data_pagamento

      t.timestamps
    end
    add_index :leituras_energia, [ :conta_energia_id, :unidade_id ], unique: true
  end
end
