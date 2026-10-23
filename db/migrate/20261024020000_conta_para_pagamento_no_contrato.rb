# A forma de pagamento sai do modelo do contrato: cada contrato escolhe a conta.
class ContaParaPagamentoNoContrato < ActiveRecord::Migration[8.1]
  def change
    add_reference :contratos, :conta_pagamento, foreign_key: true
    remove_column :configuracoes_contrato, :forma_pagamento, :text
  end
end
