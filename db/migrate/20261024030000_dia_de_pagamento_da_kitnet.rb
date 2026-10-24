class DiaDePagamentoDaKitnet < ActiveRecord::Migration[8.1]
  def change
    add_column :unidades, :dia_pagamento, :integer
  end
end
