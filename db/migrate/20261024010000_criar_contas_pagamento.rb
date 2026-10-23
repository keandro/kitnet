class CriarContasPagamento < ActiveRecord::Migration[8.1]
  def change
    create_table :contas_pagamento do |t|
      t.string :titular, null: false
      t.string :banco_codigo
      t.string :banco_nome
      t.string :agencia
      t.string :conta
      t.string :chave_pix
      t.timestamps
    end
  end
end
