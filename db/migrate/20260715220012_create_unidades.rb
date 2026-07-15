class CreateUnidades < ActiveRecord::Migration[8.1]
  def change
    create_table :unidades do |t|
      t.string :nome
      t.string :endereco
      t.decimal :valor_base
      t.integer :status

      t.timestamps
    end
  end
end
