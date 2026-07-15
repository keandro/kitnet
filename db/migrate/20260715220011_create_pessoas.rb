class CreatePessoas < ActiveRecord::Migration[8.1]
  def change
    create_table :pessoas do |t|
      t.string :nome
      t.string :cpf
      t.string :telefone
      t.string :email
      t.string :endereco

      t.timestamps
    end
  end
end
