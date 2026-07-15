class RenameContratoFiadorsToContratoFiadores < ActiveRecord::Migration[8.1]
  def change
    rename_table :contrato_fiadors, :contrato_fiadores
  end
end
