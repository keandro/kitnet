# Contratos de aluguel, independentes dos pagamentos: quem mora (inquilino),
# fiador, kitnet, valor, duração, dia de vencimento e se está ativo ou finalizado.
class CriarContratosDeAluguel < ActiveRecord::Migration[8.1]
  def change
    create_table :contratos do |t|
      t.references :unidade, null: false, foreign_key: true
      t.string :inquilino, null: false
      t.string :fiador
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.integer :duracao_meses, null: false
      t.integer :dia_vencimento, null: false
      t.date :data_inicio
      t.integer :status, null: false, default: 0
      t.text :observacoes

      t.timestamps
    end
    add_index :contratos, [ :unidade_id, :status ]
  end
end
