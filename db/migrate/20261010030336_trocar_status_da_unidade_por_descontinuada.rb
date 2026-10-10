# O status (livre/ocupada/manutenção) deixa de ser usado. Fica só a marcação
# fixa de unidade descontinuada (a antiga casa), que esconde a unidade dos
# meses depois do último pagamento.
class TrocarStatusDaUnidadePorDescontinuada < ActiveRecord::Migration[8.1]
  def up
    add_column :unidades, :descontinuada, :boolean, default: false, null: false
    execute "UPDATE unidades SET descontinuada = 1 WHERE status = 3"
    remove_column :unidades, :status
  end

  def down
    add_column :unidades, :status, :integer
    execute "UPDATE unidades SET status = CASE WHEN descontinuada = 1 THEN 3 ELSE 0 END"
    remove_column :unidades, :descontinuada
  end
end
