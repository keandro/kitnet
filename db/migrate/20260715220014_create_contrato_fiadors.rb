class CreateContratoFiadors < ActiveRecord::Migration[8.1]
  def change
    create_table :contrato_fiadors do |t|
      t.references :contrato, null: false, foreign_key: true
      t.references :pessoa, null: false, foreign_key: true

      t.timestamps
    end
  end
end
