class AddDiaPagamentoToContratos < ActiveRecord::Migration[8.1]
  def change
    add_column :contratos, :dia_pagamento, :integer
  end
end
