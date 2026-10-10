# O app passa a cuidar só do dinheiro: saem pessoas, contratos e as ordens de
# pagamento geradas por contrato. Pagamento vira um registro simples por
# kitnet (valor, data do pagamento e observações). Os pagamentos já quitados
# são mantidos, ligados à kitnet do contrato de origem.
class RemodelarParaGestaoFinanceira < ActiveRecord::Migration[8.1]
  def up
    rename_table :pagamentos, :pagamentos_antigos

    create_table :pagamentos do |t|
      t.references :unidade, null: false, foreign_key: true
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.date :data_pagamento, null: false
      t.text :observacoes

      t.timestamps
    end
    add_index :pagamentos, :data_pagamento

    execute <<~SQL
      INSERT INTO pagamentos (unidade_id, valor, data_pagamento, observacoes, created_at, updated_at)
      SELECT contratos.unidade_id, pagamentos_antigos.valor, pagamentos_antigos.data_pagamento,
             pagamentos_antigos.observacoes, pagamentos_antigos.created_at, pagamentos_antigos.updated_at
      FROM pagamentos_antigos
      JOIN contratos ON contratos.id = pagamentos_antigos.contrato_id
      WHERE pagamentos_antigos.data_pagamento IS NOT NULL
    SQL

    drop_table :pagamentos_antigos
    drop_table :contrato_fiadores
    drop_table :contratos
    drop_table :pessoas
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Pessoas e contratos foram removidos; restaure o backup em storage/ se precisar deles."
  end
end
