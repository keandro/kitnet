class CreatePagamentos < ActiveRecord::Migration[8.1]
  def change
    create_table :pagamentos do |t|
      t.references :contrato, null: false, foreign_key: true
      t.decimal :valor
      t.date :data_vencimento
      t.date :data_pagamento
      t.text :observacoes

      t.timestamps
    end
  end
end
